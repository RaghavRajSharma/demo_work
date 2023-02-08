class NotificationsSerializer < ActiveModel::Serializer

  def attributes
    data = {}
    data[:person] = [id: object.id]
    data[:preferences] = object.preferences
    return data
  end  
end
