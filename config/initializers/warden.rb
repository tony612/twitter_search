Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :rememberable, :twitter
  manager.failure_app = SessionsController
end

# Setup Session Serialization
class Warden::SessionSerializer
  def serialize(user)
    user.id.to_s
  end

  def deserialize(id)
    id = id["$oid"] unless id.is_a?(String)
    User.find(id)
  end
end

Warden::Strategies.add(:rememberable) do
  def valid?
    # When user login with 'Remember me', the cookies should be set:
    # cookies.signed['user.remember'] = jodiwjdoiwdj
    cookies.signed['user_remember_token']
  end

  def authenticate!
    if user = User.find_by_remember_token(cookies.signed['user_remember_token'])
      success! user
    else
      cookies.delete('user_remember_token')
      pass
    end
  end
end

Warden::Strategies.add(:twitter) do
  def valid?
    request.env['omniauth.auth'] && request.env['omniauth.auth'].info
  end

  def authenticate!
    env_auth = request.env['omniauth.auth']
    if u = User.find_or_create_from_auth(env_auth.uid, env_auth)
      cookies.permanent.signed['user_remember_token'] = u.id.to_s
      success!(u)
    else
      fail!("Wrong user!")
    end
  end
end

Warden::Manager.after_authentication do |user, auth, opts|
  user.remember_me!
end


Warden::Manager.before_logout do |user, auth, opts|
  user.forget_me!
  auth.response.delete_cookie "user_remember_token"
end
