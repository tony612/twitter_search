namespace :twitter do
  def save_friend_ids(client, mode='a', user=nil)
    following_ids = Thread.new { client.friend_ids(user).to_a }
    follower_ids = Thread.new { client.follower_ids(user).to_a }
    friend_ids = following_ids.value & follower_ids.value
    File.open './db/friend_ids', mode do |f|
      friend_ids.in_groups_of(10, false) do |group|
        f.write(group.join(' ') + "\n")
      end
      f.write("\n")
    end
    friend_ids
  end

  desc "List bi-follow users"
  task friends: :environment do
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.bearer_token    = ENV['TWITTER_BEARER_TOKEN']
      config.access_token    = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
    friend_ids_1 = save_friend_ids(client, 'w')
    p friend_ids_1.count

    friend_ids_2 = friend_ids_1.map do |id|
      ids = save_friend_ids(client, 'a', id)
      p ids.count
      sleep(90)
      ids
    end
    p friend_ids_2.count
    friend_ids = (friend_ids_2 << friend_ids_1).flatten.uniq
    p friend_ids.count
    File.open './db/friend_ids.txt', 'w' do |f|
      friend_ids.each do |id|
        f.write(id + "\n")
      end
    end
  end

end
