class GetNotificationSerializer < ActiveModel::Serializer
  
  def attributes
    data = super
    data[:newsletters] = newsletters
    data[:preferences] = object.preferences
    return data
  end

  def newsletters
    news_letters = {}
    options = [["Send me a daily newsletter if there are new listings", 1], ["Send me a weekly newsletter if there are new listings", 7], ["Don't send me newsletters", 100000]]
    news_letters = {options_and_Values: options, selected: object&.min_days_between_community_updates}
    return news_letters
  end
end
