class UsersController < ApplicationController
  before_action :auth!

  def show
    min = params[:min].to_i || 3
    @words_bag = current_user.words_bag.reject { |k, v| v < min }.map { |k, v| [k, v] }
  end
end
