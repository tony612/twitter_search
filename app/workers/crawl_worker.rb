class CrawlWorker
  include Sidekiq::Worker

  def perform(id)
    user = User.find(id)
    user.update_words_bag
  end
end
