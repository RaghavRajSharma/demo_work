# == Schema Information
#
# Table name: category_variable_custom_fields
#
#  id              :integer          not null, primary key
#  category_id     :integer
#  custom_field_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CategoryVariableCustomField < ApplicationRecord
  belongs_to :category
  belongs_to :variable_custom_field, class_name: "CustomField", foreign_key: "custom_field_id"
  CONFIG = {
    "Containers" => ["Manufacturer", "Model", "Container Size"],
    "Canopies" => ["Manufacturer", "Model", "Size"],
    "AADs" => ["Manufacturer", "Model"],
    "Jumpsuits" => ["Manufacturer", "Model"],
    "Altimeters" => ["Manufacturer", "Model"],
    "Altimeter Watches" => ["Manufacturer", "Model", "Size"]
  }

  def self.update_associations(debug: true) 
    self.destroy_all
    CONFIG.each do |category_name, variable_custom_fields|
      category = Category.find_by_name(category_name) 
      if category 
        variable_custom_fields.each do |variable_custom_field| 
          custom_field = CustomField.joins(:names).where(custom_field_names: { value: variable_custom_field }).last
          if custom_field 
            if category.has_subcategories? 
              category.subcategories.each do |sub_category| 
                self.find_or_create_by(category: sub_category, variable_custom_field: custom_field)
              end
            else 
              self.find_or_create_by(category: category, variable_custom_field: custom_field)
            end
          else 
            puts "Custom Field: #{variable_custom_field} not found"
            binding.pry if debug
          end
        end
      else 
        puts "Category: #{category_name} not found"
        binding.pry if debug
      end
    end
  end
end
