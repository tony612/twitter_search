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
  field :remembered_at, type: DateTime
  field :config, type: Hash, default: {}

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

  def self.find_by_remember_token(token)
    u = find(token.to_s)
    if u && u.remembered_at && u.remembered_at < Time.now
      u
    end
  end

  def remember_me!
    self.remembered_at = DateTime.now
    save(validate: false) if self.changed?
  end

  def forget_me!
    return unless persisted?
    self.remembered_at = nil
    save(validate: false)
  end

  def sort_searched_tweets(tweets)
    word_scores = []
    scores = tweets.map do |t|
      score = 0
      # score += 20 if (friends['class1'] || []).include? t.user.id
      # score += 10 if (friends['class2'] || []).include? t.user.id
      score, str = score_for_tweet(t)
      word_scores << str
      score
    end
    tweets = tweets.map.with_index.sort_by { |t, index| -scores[index] }.map(&:first)
    word_scores = word_scores.map.with_index.sort_by { |t, index| -scores[index] }.map(&:first)
    [tweets, word_scores]
  end

  def score_for_tweet(tweet)
    words = TwitterHelper.tweet_text_to_words(tweet.text)
    word_scores = []
    score = words.uniq.inject(0) do |memo, word|
      score = filtered_words_bag[word] || 0
      word_scores << "#{word},#{score}" if score != 0
      memo + score
    end
    [score, word_scores * ';']
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

  def black_list
    config['black_list'] || {}
  end

  def white_list
    config['white_list'] || {}
  end

  def update_filters!(black_list, white_list)
    self.config['black_list'] = black_list
    self.config['white_list'] = white_list
    self.save!
  end

  def filtered_words_bag
    words_bag.reject { |k, v| black_list.keys.include?(k) }
             .merge white_list
  end

end
