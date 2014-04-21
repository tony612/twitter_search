class User < ActiveRecord::Base
  def self.find_or_create_from_auth(uid, auth)
    find_or_create_by(uid: uid) do |user|
      info = auth.info
      %w[nickname name location image description].each do |m|
        user.send "#{m}=", info.send(m)
      end
      user.access_token = auth.credentials.token
    end
  end
end
