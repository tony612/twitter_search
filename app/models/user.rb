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

  def self.find_or_create_from_auth(uid, auth)
    find_or_create_by(uid: uid) do |user|
      info = auth.info
      %w[nickname name location image description].each do |m|
        user.send "#{m}=", info.send(m)
      end
      user.auth = { access_token: auth.credentials.token }
    end
  end
end
