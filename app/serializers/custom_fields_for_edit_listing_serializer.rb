class CustomFieldsForEditListingSerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :search_filter, :required, :min,  :max, :allow_decimals, :dropdown_options, :child_info, :selected_option, :selected_index

  def name
    object.name
  end

  def dropdown_options
    listing = Listing.find(self.options[:serializer_options][:listing_id])
    category_id = self.options[:serializer_options][:category_id]
    if object.name == "Manufacturer"
      return Product.products_by_category(category_id).pluck(:manufacturer).uniq.map{|m| [m,m]}
    elsif object.name == "Model"
      manufacturer_id = CustomField.joins(:names).where("custom_field_names.value = 'Manufacturer'").first.id
      if listing.custom_field_values.find_by(custom_field_id: manufacturer_id).present?
        manufacturer_name = listing.custom_field_values.find_by(custom_field_id: manufacturer_id).text_value
        names = listing.custom_field_values.find_by(custom_field_id: object.id).text_value
        models = Product.models_by_manufacturer_and_category(category_id, manufacturer_name)
        return models.map{|model| [model,model] } + [['Other', 'Other']]
      else
        return [['Other', 'Other']]
      end
    elsif object.name == "Container Size"
      manufacturer_id = CustomField.joins(:names).where("custom_field_names.value = 'Manufacturer'").first.id
      if listing.custom_field_values.find_by(custom_field_id: manufacturer_id).present?
        manufacturer_name = listing.custom_field_values.find_by(custom_field_id: manufacturer_id).text_value      
        model_id = CustomField.joins(:names).where("custom_field_names.value = 'Model'").first.id
        if listing.custom_field_values.find_by(custom_field_id: model_id).present?
          model_name = listing.custom_field_values.find_by(custom_field_id: model_id).text_value      
          category_hash = Product.category_hash(category_id)
          result = category_hash[manufacturer_name].select{|c| c[:manufacturer] == manufacturer_name && c[:model] == model_name}.first
          return container_sizes = result[:container_sizes].map{|container| [container, container]}
        end
      else
        return [['Other', 'Other']]
      end
    elsif ["Height Range", "Weight Range", "Color", "Secondary Color", "Condition", "Jump Number", "AAD ready?", "RSL?", "Original Owner?"].include?(object.name) || object.type.eql?("DropdownField")
      get_dropdown_options(object)
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

  def selected_option
    listing = Listing.find(self.options[:serializer_options][:listing_id])
    if ["Manufacturer", "Model", "Container Size"].include?(object.name)
      if listing.custom_field_values.find_by(custom_field_id: object.id).present?
        selected_value = listing.custom_field_values.find_by(custom_field_id: object.id).text_value
        result = [selected_value,selected_value]
      else
        result = ["Other","Other"]
      end  
    else
      answer = listing.answer_for(object)
      return unless answer
      case answer.type
      when "DropdownFieldValue"
        return answer.selected_options.present? ? [answer.selected_options.first.title(I18n.locale), answer.selected_options.first.id]: []
      when "TextFieldValue"
        answer.text_value
      when "NumericFieldValue"
        answer.numeric_value
      when "DateFieldValue"
        answer.date_value.present? ? answer.date_value.strftime("%Y-%m-%d") : answer.date_value
      end      
    end
  end

  def selected_index
    listing = Listing.find(self.options[:serializer_options][:listing_id])    
    if ["Manufacturer", "Model", "Container Size"].include?(object.name)
        options = dropdown_options
      if listing.custom_field_values.find_by(custom_field_id: object.id).present?
        selected_value = listing.custom_field_values.find_by(custom_field_id: object.id).text_value
        result = [selected_value,selected_value]
      else
        result = ["Other","Other"]
      end
      return selected_index = options.index(result) 
    else
      if ["Height Range", "Weight Range", "Color", "Secondary Color", "Condition", "Jump Number", "AAD ready?", "RSL?", "Original Owner?"].include?(object.name) || object.type.eql?("DropdownField")  
        options = get_dropdown_options(object)
        answer = listing.answer_for(object)
        result = answer.present? && answer.selected_options.present? ? [answer.selected_options.first.title(I18n.locale), answer.selected_options.first.id]: []
        return selected_index = options.index(result)
      else
        return nil
      end  
    end
  end

  private 
    def get_dropdown_options(custom_field)
      return custom_field.options.sort.collect { |opt| [opt.title(I18n.locale), opt.id] }
    end 
end
