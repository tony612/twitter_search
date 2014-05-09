class TwitterHelper
  class << self

    def handle_rate_limit
      max_attempts = 3
      num_attempts = 0
      begin
        num_attempts += 1
        yield if block_given?
      rescue Twitter::Error::TooManyRequests => error
        if num_attempts <= max_attempts
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

  end
end
