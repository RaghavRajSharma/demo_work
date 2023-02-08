class ProductCategorySerializer < ActiveModel::Serializer
  attributes :id, :subcategory, :parent
  def parent 
    Category.find(object.parent_id).url
  end

  def subcategory
    object.url
  end
end
