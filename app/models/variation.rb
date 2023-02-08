# == Schema Information
#
# Table name: variations
#
#  id             :integer          not null, primary key
#  product_id     :integer
#  attribute_name :string(255)
#  value          :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_variations_on_product_id  (product_id)
#

class Variation < ApplicationRecord
  belongs_to :product

  validates :product_id, :attribute_name, :value, presence: true
end
