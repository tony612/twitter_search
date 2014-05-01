class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def user_signed_in?
    warden.authenticated?
  end
  helper_method :user_signed_in?

  def current_user
    env['warden'].user
  end

end
