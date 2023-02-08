class GetProfileInfoSerializer < ActiveModel::Serializer

  def attributes
    data = {}
    data[:id] = object.id
    data[:first_name] = object.given_name
    data[:last_name] = object.family_name
    data[:display_name] = object.display_name
    data[:jump] = jump
    data[:association] = association
    data[:membership]= object.membership_number
    data[:license_type] = license_type
    data[:license_number] = object.license_number
    data[:ratings] = ratings
    data[:profession] = profession
    data[:fvorite_discipline] = fvorite_discipline
    data[:other_disciplines] = other_disciplines
    data[:jumpin_since] = jumpin_since
    data[:home_drop_zone] = home_drop_zone
    data[:other_drop_zones] = other_drop_zones
    data[:location] = object.location.present? ? object.location : {}
    data[:phone_number] = object.phone_number
    data[:profile_picture] = profile_picture
    data[:about_you] = object.description
    return data
  end

  def jump
    options_array = []
    ProfileCustomField.find_by(name: "Jump #").options.each do |option|
      options_array << [option&.name, option&.name]
    end
    jump = {jump_options_and_values: options_array, selected_option_index: options_array.index{|i| i[0] == object.jump_number}, selected_option_value: object.jump_number }
    return jump
  end

  def profile_picture
    object&.image.present? ? object&.image&.url(:thumb) : "https://theflyingflea.com/assets/profile_image/thumb/missing.png"
  end

  def association
    options_array = []
    ProfileCustomField.find_by(name: "Association").options.each do |association|
      options_array << [association.name, association.name]
    end
    associations = {association_options_and_values: options_array, selected_option_index: options_array.index{|i| i[0] == object.membership_association}, selected_option_value: object.membership_association}
    return associations
  end

  def license_type
    options_array = []
    ProfileCustomField.find_by(name: "License").options.each do |license_type|
      options_array << [license_type.name, license_type.name]
    end
    license_types = {license_type_options_and_values: options_array, selected_option_index: options_array.index{|i| i[0] == object.license_type}, selected_option_value: object.license_type}
    return license_types
  end

  def ratings
    rating_options = Rating.all.pluck(:id, :name)
    ratings = {ratings_options_and_values: rating_options, selected_option: object.rating_ids}
    return ratings
  end

  def profession
    options_array = []
    ProfileCustomField.find_by(name: "Profession").options.each do |profession|
      options_array << [profession.name, profession.name]
    end
    professions = {professions_options_and_values: options_array, selected_option_index: options_array.index{|i| i[0] == object.profession}, selected_option_value: object.profession}
    return professions 
  end

  def fvorite_discipline
    options_array = Discipline.all.map{|d| [d.name, d.id.to_s]}
    fvorite_disciplines = {favourite_discipline_options_and_values: options_array, selected_option_index: options_array.index{|i| i[1] == object.favorite_discipline&.id.to_s}, selected_option_value: object.favorite_discipline&.id.to_s}
    return fvorite_disciplines
  end

  def other_disciplines
    options_array = Discipline.all.pluck(:id, :name)
    other_disciplines = {other_discipline_options_and_values: options_array, selected_option: object.discipline_ids}
    return other_disciplines
  end 

  def jumpin_since 
    options_array = []
    ProfileCustomField.find_by(name: "Jumpin' since").options.each do |jumpin_since|
      options_array << [jumpin_since.name, jumpin_since.name]
    end
    jumpin_sinces = {jumpin_since_options_and_values: options_array, selected_option_index: options_array.index{|i| i[0] == object.jumping_since.to_s}, selected_option_value: object.jumping_since.to_s}
    return jumpin_sinces    
  end

  def home_drop_zone
    options_array = DropZone.all.map{|dz| [dz.name_and_location, dz.id]}
    home_drop_zones = {home_drop_zone_options_and_values: options_array, selected_option_index: options_array.index{|i| i[0] == object.home_dropzone_name}, selected_option_value: object.home_dropzone_name}
    return home_drop_zones
  end

  def other_drop_zones
    options_array = DropZone.all.map{|dz| {id: dz.id.to_s, name: dz.name_and_location, }}
    other_drop_zones = {other_drop_zones_options_and_values: options_array, selected_option: object.dropzones.pluck(:id)}
    return other_drop_zones    
  end
end