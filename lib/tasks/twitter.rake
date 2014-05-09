namespace :twitter do
  def find_friend_ids(client, uid)
    uid = uid.to_i
    following_ids = Thread.new { client.friend_ids(uid).to_a }
    follower_ids = Thread.new { client.follower_ids(uid).to_a }
    following_ids.value & follower_ids.value
  end

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.bearer_token    = ENV['TWITTER_BEARER_TOKEN']
      config.access_token    = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
  end

  def update_user_friends(uid, ids, class_n='class1')
    user = User.find_by(uid: uid)
    user.friends[class_n] = ids
    user.save!
  end

  desc "update friends"
  task :friends, [:user_id] => :environment do |t, args|
    uid = args[:user_id]
    ids = find_friend_ids(client, uid)
    update_user_friends(uid, ids)

    ids2 = ids.map do |id|
      begin
        find_friend_ids(client, id)
        sleep(90)
      rescue e
        p e
        []
      end
    end.flatten
    update_user_friends(uid, id2, 'class2')
  end
end
