require 'twitter_helper'

class User
  include Mongoid::Document

  field :uid, type: Integer
  field :nickname
  field :name
  field :location
  field :image
  field :description
  field :auth, type: Hash
  field :friends, type: Hash, default: {}
  field :words_bag, type: Hash, default: {}

  def self.find_or_create_from_auth(uid, auth)
    find_or_create_by(uid: uid) do |user|
      info = auth.info
      %w[nickname name location image description].each do |m|
        user.send "#{m}=", info.send(m)
      end
      user.auth = { access_token: auth.credentials.token,
                    access_secret: auth.credentials.secret }
    end
  end

  def sort_searched_tweets(tweets)
    scores = tweets.map do |t|
      score = 0
      score += 20 if (friends['class1'] || []).include? t.user.id
      score += 10 if (friends['class2'] || []).include? t.user.id
      score
    end
    tweets.map.with_index.sort_by { |t, index| scores[index] }.map(&:first)
  end

  def get_all_tweets
    client = TwitterHelper.client_with_access(
      auth['access_token'],
      auth['access_secret']
    )

    client = TwitterHelper.add_all_tweets_ability(client)

    TwitterHelper.handle_rate_limit do
      client.get_all_tweets(nickname)
    end
  end

  def update_words_bag
    tweets = get_all_tweets

    words_bag = Hash.new(0)
    tweets.each do |tweet|
      words = TwitterHelper.tweet_text_to_words(tweet.text)
      words.each { |word| words_bag[word] += 1 }
    end
    self.words_bag = words_bag
    self.save!
  end

end
