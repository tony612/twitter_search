class SearchController < ApplicationController
  def index
  end

  def search
    query = params[:q]
    if query.present?
      client = Twitter::REST::Client.new do |config|
        config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.bearer_token    = ENV['TWITTER_BEARER_TOKEN']
      end
      @tweets = client.search(query, :result_type => "recent").take(20)
    else
      flash[:warning] = 'Please input the keywords'
      @tweets = []
    end
  end
end
