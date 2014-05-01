class SessionsController < ApplicationController
  def create
    warden.authenticate!(:twitter)
    redirect_to '/', notice: "Authing successful"
  end

  def destroy
    env['warden'].logout
    redirect_to root_path
  end
end
