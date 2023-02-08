class GetAccountSerializer < ActiveModel::Serializer
  def attributes
    data = super
    data[:id] = object.id
    data[:username] =  object.username
    data[:email_addresses] = email_addresses
    return data
  end

  def email_addresses
    emails_array = []
    object.emails.each do |email|
      confirmation = email.confirmed_at ? "Confirmed" : "Pending"
      emails_array << {id: email.id, address: email&.address, confirmation: confirmation, receive_notifications: email.send_notifications}
    end
    return emails_array
  end
end
