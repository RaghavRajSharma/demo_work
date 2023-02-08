
require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/profile_custom_fields/attributes'
require_relative './data/profile_custom_fields/ratings'
require_relative './data/profile_custom_fields/disciplines'
require_relative './data/profile_custom_fields/dropzones'

def add_profile_custom_fields 
  ProfileCustomFieldOption.destroy_all
  ProfileCustomField.destroy_all
  attributes.each do |attribute, options|
    field = ProfileCustomField.create(name: attribute)
    options.each do |option|
      field.options.create(name: option)
    end
  end
  add_ratings
  add_disciplines
  add_dropzones
end

def add_ratings 
  Rating.destroy_all
  ratings.each do |rating|
    Rating.create(name: rating)
  end
end

def add_disciplines 
  Discipline.destroy_all 
  disciplines.each do |discipline| 
    Discipline.create(name: discipline)
  end
end

def add_dropzones
  DropZone.destroy_all
  dropzones.each do |name, details| 
    DropZone.create(details)
  end
end