require_relative './data/categories'

def add_categories
  params = 	{
    "listing_shapes"=>[{"listing_shape_id"=>"1"}], 
    "button"=>"", 
    "controller"=>"admin/categories", 
    "action"=>"create", 
    "locale"=>"en"
  } 
  
  @current_community = Community.first
  start = 2
  offset = 0
  categories_hash.each do |category, sub_categories|
    parent = category
    puts parent
    parent_params = {
      "category"=>{"translation_attributes"=>{"en"=>{"name"=>"#{parent}"}}},
      "parent_id"=>""
    }
    parent_id = start + offset
    p = params.merge(parent_params)
    submit_category(p)
    offset += 1
    puts sub_categories.inspect
    sub_categories.each do |sub_category|
      child_params = {
        "category"=>{"translation_attributes"=>{"en"=>{"name"=>"#{sub_category}"}}},
        "parent_id"=>"#{parent_id}"
      }
      p = params.merge(child_params)
      submit_category(p, parent_id)
      offset += 1
      puts child_params.inspect
    end
  end
  Category.first.destroy
end

def submit_category(params, parent_id=nil)
  category = Category.new(params["category"])
  category.parent_id = parent_id
  category.community = @current_community
  category.sort_priority = Admin::SortingService.next_sort_priority(@current_community.categories)
  shapes = @current_community.shapes
  selected_shape_ids = shape_ids_from_params(params)

  if category.save 
    update_category_listing_shapes(selected_shape_ids, category)
  end
end

def shape_ids_from_params(params)
  # puts params.inspect
  params["listing_shapes"].map { |s_param| s_param["listing_shape_id"].to_i }
end

def update_category_listing_shapes(shape_ids, category)
  selected_shapes = @current_community.shapes.select { |s| shape_ids.include? s[:id] }

  raise ArgumentError.new("No shapes selected for category #{category.id}, shape_ids: #{shape_ids}") if selected_shapes.empty?

  CategoryListingShape.where(category_id: category.id).delete_all

  selected_shapes.each { |s|
    CategoryListingShape.create!(category_id: category.id, listing_shape_id: s[:id])
  }
end