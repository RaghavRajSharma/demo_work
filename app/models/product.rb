# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  category_id  :integer
#  manufacturer :string(255)
#  model        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_products_on_category_id  (category_id)
#

class Product < ApplicationRecord
  belongs_to :category
  has_many :variations

  validates :category_id, :manufacturer, :model, presence: true
  validates :model, uniqueness: { scope: [:manufacturer, :category_id] }

  # Consider adding a whitelist for attributes from the category's custom fields
  def self.new_from_hash(hash)
    if hash["Type"] && !hash["Type"].blank?
      category = Category.find_by_url(format_category_url(hash["Type"]))
      category = Category.find_by_name(hash["Type"]) unless category
      binding.pry unless category
      throw "Category: #{hash["Type"]} does not exist" unless category 
      product = category.products.find_or_create_by(manufacturer: hash["Manufacturer"], model: hash["Model"])
    else 
      throw "Must pass a Type key"
    end
    if product.persisted?
      hash.each do |key, value| 
        product.add_variations(key, value) unless ["Manufacturer", "Model", "Type"].include?(key)
      end
    else 
      throw "Product could not be created because of: #{product.errors.messages}"
    end
    product
  end

  def self.category_hash(id_or_url)
    hash = {}
    hash[:manufacturers] = []
    hash[:products] = []
    category = Category.find_by_url_or_id(id_or_url)
    throw "invalid category id_or_url specified: #{id_or_url}" unless category 
    if category.has_subcategories?
      "Try requesting manufacturers for one of this category's subcategories: #{category.subcategory_ids}"
    else
      category.products.each do |product|
        
        if hash[product[:manufacturer]]
          hash[product[:manufacturer]] << {
            manufacturer: product[:manufacturer],
            model: product[:model],
            sizes: product.options_for('size'),
            container_sizes: product.options_for('Container Size'),
            harness_sizes: product.options_for('Harness Size')
          }
        else 
          hash[product[:manufacturer]] = [
            {
              manufacturer: product[:manufacturer],
              model: product[:model], 
              sizes: product.options_for('size'),
              container_sizes: product.options_for('Container Size'),
              harness_sizes: product.options_for('Harness Size')
            }
          ]
          hash[:manufacturers] << product[:manufacturer]
        end
        
        puts product.attributes
      end
    end
    hash
  end

  def self.products_by_category(id_or_url) 
    category = Category.find_by_url_or_id(id_or_url)
    throw "invalid category id_or_url specified" unless category 
    if category.has_subcategories?
      "Try requesting manufacturers for one of this category's subcategories: #{category.subcategory_ids}"
    else
      self.where(category: category)
    end
  end

  def self.manufacturers_by_category(id_or_url)
    category = Category.find_by_url_or_id(id_or_url)
    throw "invalid category id_or_url specified" unless category 
    if category.has_subcategories?
      "Try requesting manufacturers for one of this category's subcategories: #{category.subcategory_ids}"
    else
      self.where(category: category).pluck(:manufacturer).uniq
    end
  end

  def self.models_by_category(id_or_url)
    category = Category.find_by_url_or_id(id_or_url)
    throw "invalid category id_or_url specified" unless category 
    if category.has_subcategories?
      "Try requesting manufacturers for one of this category's subcategories: #{category.subcategory_ids}"
    else
      self.where(category: category).pluck(:model).uniq
    end
  end

  def self.models_by_manufacturer_and_category(id_or_url, manufacturer_name)
    category = Category.find_by_url_or_id(id_or_url)
    throw "invalid category id_or_url specified" unless category 
    if category.has_subcategories?
      "Try requesting models for one of this category's subcategories: #{category.subcategory_ids}"
    else
      self.where(category: category, manufacturer: manufacturer_name).pluck(:model).uniq
    end
  end

  def self.find_by_category_manufacturer_and_model_name(id_or_url, manufacturer_name, model_name)
    category = Category.find_by_url_or_id(id_or_url)
    throw "invalid category id_or_url specified" unless category 
    if category.has_subcategories?
      throw "Try requesting models for one of this category's subcategories: #{category.subcategory_ids}"
    else
      self.find_by(category: category, manufacturer: manufacturer_name, model: model_name)
    end
  end

  def self.category_manufacturer_model_sizes(id_or_url, manufacturer_name, model_name)
    self.find_by_category_manufacturer_and_model_name(id_or_url, manufacturer_name, model_name).options_for('size')
  end

  def self.category_manufacturer_model_variations(id_or_url, manufacturer_name, model_name)
    self.find_by_category_manufacturer_and_model_name(id_or_url, manufacturer_name, model_name).variations
  end

  def add_variations(type, values) 
    format_as_array(values).each do |value|
      variations.find_or_create_by(attribute_name: type.downcase, value: value)
    end
  end

  def options_for(attribute) 
    variations.where(attribute_name: attribute.downcase).map{ |v| v.value }
  end

  def options 
    hash = {}
    variations.map do |variation| 
      if hash[variation.attribute_name] 
        hash[variation.attribute_name] << variation.value
      else 
        hash[variation.attribute_name] = [variation.value]
      end
    end
    hash
  end

  def self.custom_field_ids(category_id)
    @@custom_field_ids ||= get_custom_field_ids
    category = Category.find_by(id: category_id)
    if category 
      category_url = category.url 
    else 
      category_url = "Category not found"
    end

    @@custom_field_ids.merge({
      category_url: category_url,
      variable_custom_field_ids: category.variable_custom_field_ids
    })
  end

  def self.get_custom_field_ids 
    manufacturer_id = "" 
    model_id = "" 
    size_id = "" 
    container_size_id = ""
    dom_date_id = ""
    CustomField.all.each do |cf|
      if cf.name == "Manufacturer" 
        manufacturer_id = cf.id 
      elsif cf.name == "Model" 
        model_id = cf.id 
      elsif cf.name == "Size" 
        size_id = cf.id 
      elsif cf.name == "Container Size"
        container_size_id = cf.id
      elsif cf.name == "DOM" 
        dom_date_id = cf.id
      end
    end
    {
      manufacturer_id: manufacturer_id,
      model_id: model_id,
      size_id: size_id,
      container_size_id: container_size_id,
      dom_date_id: dom_date_id
    }
  end

  def self.refresh_custom_field_ids 
    @@custom_field_ids = nil
    puts "cached custom fields ids have been cleared"
  end

  private 
  
  def format_as_array(input)
    input.class == String ? input.split(',').map(&:strip) : input
  end

  def self.format_category_url(category_name)
    category_name.downcase.gsub(/&/, 'and').gsub(/\//, '-slash-').gsub(/[\.\(\)]/,'').split(' ').join('-')
  end

end
