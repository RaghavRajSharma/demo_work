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

class ProductSerializer < ActiveModel::Serializer
  attributes :id, :manufacturer, :model, :options, :category
  def category 
    object.category.slice(:id, :url) unless category_specific
  end
  #belongs_to :category, serializer: ProductCategorySerializer unless controller.category_specific

  def sizes 
    object.options["size"]
  end
end
