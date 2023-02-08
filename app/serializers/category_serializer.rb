# == Schema Information
#
# Table name: categories
#
#  id            :integer          not null, primary key
#  parent_id     :integer
#  icon          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  community_id  :integer
#  sort_priority :integer
#  url           :string(255)
#
# Indexes
#
#  index_categories_on_community_id  (community_id)
#  index_categories_on_parent_id     (parent_id)
#  index_categories_on_url           (url)
#

class CategorySerializer < ActiveModel::Serializer
  #attributes :id, :name, :url, :subcategories
  #has_many :custom_fields, :serializer => CustomFieldSerializer, serializer_params: { category_id: 2}
  def attributes
    data = super
    data[:name] = object.display_name('en')
    data[:url] = object.url
    data[:subcategories] =  object.subcategories
    data[:custom_fields] = custom_fields
    data[:filters] = custom_filters
    return data
  end

  def custom_fields
    custom_fields = []
    object.custom_fields.each do |custom_field|
      custom_fields << CustomFieldSerializer.new(custom_field, root: false, serializer_options: {category_id: object.id})
    end
    return custom_fields    
  end

  def custom_filters
    category = Category.find_by(url: object.url)
    category_custom_fields = CategoryCustomField.find_by_category_and_subcategory(category)
    custom_fields = []
    category_custom_fields.each do |custom_field|
      custom_fields << CustomField.find(custom_field[:custom_field_id])
    end
    custom_fields = custom_fields.uniq
    result = []
    custom_fields.each do |field|
      options_param = []
      field.with_type do |type|
        if [:dropdown, :checkbox].include?(type)
          field.options.sort.each_with_index do |option, i|
            param_name = type == :dropdown ? CustomFieldSearchParams.dropdown_param_name(option.id) : CustomFieldSearchParams.checkbox_param_name(option.id)
            options_param  << {option_title: option.title(I18n.locale), param_name: param_name, value: option.id}
          end
        end
      end
    result << {title: field.name(I18n.locale), options_param: options_param} if options_param.present?
    end
    return result
  end  
end
