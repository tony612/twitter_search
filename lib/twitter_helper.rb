require 'lingua/stemmer'

class TwitterHelper
  class << self
    MAX_ATTEMPTS = 3

    StopWords = %w{a able about across after all almost also am among an and any
      are as at be because been but by can cannot could dear did do does either
      else ever every for from get got had has have he her hers him his how however
      i if in into is it its just least let like likely may me might most must my
      neither no nor not of off often on only or other our own rather said say says
      she should since so some than that the their them then there these they this
      tis to too twas us wants was we were what when where which while who whom why
      will with would yet you your want rt twitter use good cool cc have
    }

    def handle_rate_limit
      num_attempts = 0
      begin
        num_attempts += 1
        yield if block_given?
      rescue Twitter::Error::TooManyRequests => error
        if num_attempts <= MAX_ATTEMPTS
          p num_attempts, error.rate_limit.reset_in
          sleep error.rate_limit.reset_in + 1
          retry
        else
          raise
        end
      end
    end

    def client_with_access(token, secret)
      client = Twitter::REST::Client.new do |config|
        config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.bearer_token    = ENV['TWITTER_BEARER_TOKEN']
        config.access_token    = token
        config.access_token_secret = secret
      end
    end

    # Up to 3200 https://dev.twitter.com/docs/api/1.1/get/statuses/user_timeline
    def add_all_tweets_ability(client)
      def collect_with_max_id(collection=[], max_id=nil, &block)
        response = yield(max_id)
        collection += response
        response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
      end

      def client.get_all_tweets(user)
        collect_with_max_id do |max_id|
          options = {:count => 200, :include_rts => true}
          options[:max_id] = max_id unless max_id.nil?
          user_timeline(user, options)
        end
      end
      client
    end

    def tweet_text_to_words(text)
      # remove url
      # change gooooood to good
      # Remove stop words, and single letter
      # Stemming
      text_arr = text.downcase.gsub(/https?:\/\/\S+/, '')
        .split(/\W+/)
        .select { |word| word =~ /^[a-zA-Z]/ }
        .map { |word| word.gsub(/(\w)\1+/, '\1\1') }
        .reject { |word| StopWords.include?(word) || word.length == 1 }
        .map { |word| Lingua.stemmer(word) }
    end

  end
end
