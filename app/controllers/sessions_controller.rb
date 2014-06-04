class SessionsController < ApplicationController
  def create
    warden.authenticate!
    CrawlWorker.perform_async(current_user.id.to_s)
    redirect_to '/', notice: "Authing successful"
  end

  def destroy
    env['warden'].authenticated?
    env['warden'].logout
    redirect_to root_path
  end
end
