class ProfileInfoSerializer < ActiveModel::Serializer

  def attributes
    data = {}
    data[:id] = object.id
    data[:first_name] = object.given_name
    data[:last_name] = object.family_name
    data[:display_name] = object.display_name
    data[:Jump] = object.jump_number
    data[:membership_association] = object.membership_association
    data[:license_type] = object.license_type
    data[:license_number] = object.license_number
    data[:rating_ids] = object.rating_ids
    data[:profession] =  object.profession
    data[:favorite_discipline_id] = object.favorite_discipline&.id
    data[:Other_disciplines] = object.discipline_ids
    data[:jumping_since] = object.jumping_since
    data[:home_dropzone_name] = object.home_dropzone_name
    data[:other_drop_zones] = object.dropzones.pluck(:id)
    data[:location] = object.location.present? ? object.location : {}
    data[:phone_number] = object.phone_number
    data[:image_path] = object.image.present? ? object.image.url(:thumb) : "https://theflyingflea.com/assets/profile_image/thumb/missing.png"
    data[:about_me] = object.description
    return data
  end
end
