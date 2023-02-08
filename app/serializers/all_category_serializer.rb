class AllCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :parent_id, :is_parent

  def name
    object.display_name('en')
  end

  def is_parent
    object.children.blank? ? false : true
  end
end
