class UsersController < ApplicationController
  before_action :auth!

  def show
    min = params[:min].to_i || 3
    @words_bag = current_user.filtered_words_bag.reject { |k, v| v < min }.map { |k, v| [k, v] }
  end

  def filter
    @black_list = current_user.black_list.keys
    @white_list = current_user.white_list.keys
  end

  def update_filter
    blacks = params[:black_list]
    whites = params[:white_list]
    current_user.update_filters!(Hash[blacks.split(',').zip([20] * blacks.length)],
                                Hash[whites.split(',').zip([20] * whites.length)])
    redirect_to action: :filter
  end
end
