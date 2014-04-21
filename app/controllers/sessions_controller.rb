class SessionsController < ApplicationController
  def create
    warden.authenticate!(:twitter)
    redirect_to '/', notice: "Authing successful"
  end
end
