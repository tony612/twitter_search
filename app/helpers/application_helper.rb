module ApplicationHelper
  def search_placeholder
    user_signed_in? ? 'Personalized search' : 'Normal search'
  end
end
