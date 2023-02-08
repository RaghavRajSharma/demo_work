# == Schema Information
#
# Table name: custom_fields
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  sort_priority  :integer
#  search_filter  :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :integer
#  required       :boolean          default(TRUE)
#  min            :float(24)
#  max            :float(24)
#  allow_decimals :boolean          default(FALSE)
#
# Indexes
#
#  index_custom_fields_on_community_id   (community_id)
#  index_custom_fields_on_search_filter  (search_filter)
#

class CustomFieldSerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :search_filter, :required, :min,  :max, :allow_decimals, :dropdown_options, :child_info

  def name
    object.name
  end

  def dropdown_options
    if object.name == "Manufacturer"
      return Product.products_by_category(self.options[:serializer_options][:category_id]).pluck(:manufacturer).uniq.map{|m| [m,m]}
      #return [['Select one...', nil]] + manufacturer_options + [['Other', 'Other']]
    elsif ["Model", "Container Size"].include?(object.name)
      return [['Select one...', nil], ['Other', 'Other']]
    elsif ["Height Range", "Weight Range", "Color", "Secondary Color", "Condition", "Jump Number", "AAD ready?", "RSL?", "Original Owner?"].include?(object.name) || object.type.eql?("DropdownField")
      get_dropdown_options(object)
    elsif object.name == "DOM"
      dom = []
      dom << {"custom_fields[11][(1i)]" => ((Date.today.year - 20)..Date.today.year).to_a}
      dom << {"custom_fields[11][(2i)]" => [['January', 1], ['February',2],['March', 3],['April', 4],['May', 5], ['june', 6],  ['july', 7], ['August', 8], ['September', 9], ['October', 10], ['November', 11], ['December', 12]]}
      dom << {"custom_fields[11][(3i)]" => (1..31).to_a}
      return dom
    end  
  end

  def child_info
    if object.name == "Manufacturer"
      child_info = {
        id: Category.find(self.options[:serializer_options][:category_id]).custom_fields.select{|s| s.name == "Model"}[0]&.id,
        type: "dropdown",
        url: "api/v1/listings/get_models_by_manufacturer"
      }
    elsif object.name == "Model"
      child_info = {
        id: Category.find(self.options[:serializer_options][:category_id]).custom_fields.select{|s| s.name == "Container Size"}[0]&.id,
        type: "dropdown",
        url: "api/v1/listings/get_container_sizes_by_model"
      }      
    elsif object.name == "Container Size"
      child_info = {
        id: nil,
        type: "dropdown",
        url: nil
      }
    else
      child_info = {}
    end
  end

  private 
    def get_dropdown_options(custom_field)
      return custom_field.options.sort.collect { |opt| [opt.title(I18n.locale), opt.id] }
    end 
end 
