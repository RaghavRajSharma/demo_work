
require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/custom_fields'

def add_custom_fields
  priority = 0
  custom_fields.each do |custom_field_params|
    params = AddCustomFields.merge_params(custom_field_params.merge({"sort_priority"=>priority}))
    AddCustomFields.submit_form(params)
    puts params
    priority += 1
  end
  CategoryVariableCustomField.update_associations
end

private
class AddCustomFields 
  extend Analytics

  def self.merge_params(config = {})
    base_params = {
      utf8: "✓",
      custom_field: {
        :name_attributes=>{en: "#{config["field_name"]}"},
        :required => "#{config["required?"]}",
        :category_attributes =>[

        ],
        :option_attributes => {

        }
      },
      :field_type=>"#{config["field_type"]}",
      :controller=>"admin/custom_fields",
      :action=>"create",
      :locale=>"en"
    }
    if config["sort_priority"]
      base_params[:custom_field][:sort_priority] = config["sort_priority"]
    end
    base_params[:custom_field][:search_filter] = config["search_filter?"] unless ['TextField', 'DateField'].include?(config["field_type"])
    if config["categories_it_applies_to"].downcase == "all"
      Category.all.select { |c| !c.has_subcategories? || c.is_subcategory? }.each do |category|
        base_params[:custom_field][:category_attributes] << { :category_id=>"#{category.id}" }
      end
    else
      categories = config["categories_it_applies_to"].split(',').map(&:strip)
      categories.each do |category_name|
        category = Category.find_by_url(format_category_url(category_name))
        binding.pry unless category
        if category.has_subcategories?
          category.subcategories.each do |subcategory|
            base_params[:custom_field][:category_attributes] << {:category_id=>"#{subcategory.id}"}
          end
        else
          base_params[:custom_field][:category_attributes] << {:category_id=>"#{category.id}"}
        end
      end

    end
    if config["choices"] && config["field_type"] == "DropdownField"
      config["choices"].split(',').map(&:strip).each.with_index(1) do |choice, index|
        key = index < 3 ? "new-#{index}" : "jsnew-#{index-2}"
        base_params[:custom_field][:option_attributes][key] = {
          :id=>key,
          :title_attributes=>{:en=>choice.gsub('^',',')},
          :sort_priority=>"#{index}"
        }
      end
    end
    base_params
  end

  def self.submit_form(params)
    @community = Community.first

    # Hack for comma/dot issue. Consider creating an app-wide comma/dot handling mechanism
    params[:custom_field][:min] = ParamsService.parse_float(params[:custom_field][:min]) if params[:custom_field][:min].present?
    params[:custom_field][:max] = ParamsService.parse_float(params[:custom_field][:max]) if params[:custom_field][:max].present?

    custom_field_entity = build_custom_field_entity(params[:field_type], params[:custom_field])

    custom_field = params[:field_type].constantize.new(custom_field_entity) #before filter checks valid field types and prevents code injection
    custom_field.community = @community

    success =
      if valid_categories?(@community, params[:custom_field][:category_attributes])
        custom_field.save
      else
        false
      end
    if success
      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(@community.id)
        .update_from_event(:custom_field_created, custom_field)
      if state_changed
        record_event({}, "km_record", {km_event: "Onboarding filter created"})
      end
    end
  end

  def self.format_category_url(category_name)
    category_name.downcase.gsub(/&/, 'and').gsub(/\//, '-slash-').gsub(/\./,'').split(' ').join('-')
  end

  CategoryAttributeSpec = EntityUtils.define_builder(
    [:category_id, :fixnum, :to_integer, :mandatory]
  )

  OptionAttribute = EntityUtils.define_builder(
    [:id, :mandatory],
    [:sort_priority, :fixnum, :to_integer, :mandatory],
    [:title_attributes, :hash, :to_hash, :mandatory]
  )

  CHECKBOX_TO_BOOLEAN = ->(v) {
    if v == false || v == true
      v
    elsif v == "1"
      true
    else
      false
    end
  }

  HASH_VALUES = ->(v) {
    if v.is_a?(Array)
      v
    elsif v.is_a?(Hash)
      v.values
    elsif v == nil
      nil
    else
      raise ArgumentError.new("Illegal argument given to transformer: #{v.to_inspect}")
    end
  }

  CUSTOM_FIELD_SPEC = [
    [:name_attributes, :hash, :mandatory],
    [:category_attributes, collection: CategoryAttributeSpec],
    [:sort_priority, :fixnum, :optional],
    [:required, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
  ]

  TextFieldSpec = [
    [:search_filter, :bool, const_value: false]
  ] + CUSTOM_FIELD_SPEC

  NumericFieldSpec = [
    [:min, :mandatory],
    [:max, :mandatory],
    [:allow_decimals, :bool, :mandatory, transform_with: CHECKBOX_TO_BOOLEAN],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
  ] + CUSTOM_FIELD_SPEC

  DropdownFieldSpec = [
    [:option_attributes, :mandatory, transform_with: HASH_VALUES, collection: OptionAttribute],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN],
  ] + CUSTOM_FIELD_SPEC

  CheckboxFieldSpec = [
    [:option_attributes, :mandatory, transform_with: HASH_VALUES, collection: OptionAttribute],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
  ] + CUSTOM_FIELD_SPEC

  DateFieldSpec = [
    [:search_filter, :bool, const_value: false]
  ] + CUSTOM_FIELD_SPEC

  TextFieldEntity     = EntityUtils.define_builder(*TextFieldSpec)
  NumericFieldEntity  = EntityUtils.define_builder(*NumericFieldSpec)
  DropdownFieldEntity = EntityUtils.define_builder(*DropdownFieldSpec)
  CheckboxFieldEntity = EntityUtils.define_builder(*CheckboxFieldSpec)
  DateFieldEntity     = EntityUtils.define_builder(*DateFieldSpec)

  def self.build_custom_field_entity(type, params)
    params = params.respond_to?(:to_unsafe_hash) ? params.to_unsafe_hash : params
    case type
    when "TextField"
      TextFieldEntity.call(params)
    when "NumericField"
      NumericFieldEntity.call(params)
    when "DropdownField"
      DropdownFieldEntity.call(params)
    when "CheckboxField"
      CheckboxFieldEntity.call(params)
    when "DateField"
      DateFieldEntity.call(params)
    end
  end

  def self.valid_categories?(community, category_attributes)
    is_community_category = category_attributes.map do |category|
      community.categories.any? { |community_category| community_category.id == category[:category_id].to_i }
    end

    is_community_category.all?
  end
end

