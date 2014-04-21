Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :twitter
  manager.failure_app = SessionsController
end

# Setup Session Serialization
class Warden::SessionSerializer
  def serialize(user)
    user.id
  end

  def deserialize(id)
    User.find(id)
  end
end

Warden::Strategies.add(:twitter) do
  def valid?
    request.env['omniauth.auth'] && request.env['omniauth.auth'].info
  end

  def authenticate!
    env_auth = request.env['omniauth.auth']
    if u = User.find_or_create_from_auth(env_auth.uid, env_auth)
      success!(u)
    else
      fail!("Wrong user!")
    end
  end
end
