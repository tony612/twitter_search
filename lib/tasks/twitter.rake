require 'twitter_helper'

namespace :twitter do
  def find_friend_ids(client, uid)
    uid = uid.to_i

    TwitterHelper.handle_rate_limit { client.friend_ids(uid).to_a } &
    TwitterHelper.handle_rate_limit { client.follower_ids(uid).to_a }
  end

  def update_user_friends(uid, ids, class_n='class1')
    user = User.find_by(uid: uid)
    user.friends[class_n] = ids
    user.save!
  end

  desc "update friends"
  task :friends, [:user_id] => :environment do |t, args|
    uid = args[:user_id]
    user = User.find_by(uid: uid)
    client = TwitterHelper.client_with_access(
      user.auth['access_token'],
      user.auth['access_secret']
    )

    ids = find_friend_ids(client, uid)
    update_user_friends(uid, ids)

    ids2 = ids.map do |id|
      p id
      find_friend_ids(client, id)
    end.flatten
    update_user_friends(uid, id2, 'class2')
  end

  desc "update tweets words bag"
  task :update_words_bag, [:user_id] => :environment do |t, args|
    uid = args[:user_id]
    user = User.find_by(uid: uid)

    user.update_words_bag
  end
end
