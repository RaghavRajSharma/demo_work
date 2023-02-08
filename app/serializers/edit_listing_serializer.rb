class EditListingSerializer < ActiveModel::Serializer

  def attributes
    data = super
    data[:is_category] = object.category.parent_id.present? ? true :false
    data[:is_subcategory] = object.category.parent.present? && object.category.parent.subcategories.present? ? true : false
    data[:community_id] = object.community_id
    data[:author_id] = object.author_id
    data[:title] = object.title
    data[:length] = object.length
    data[:width] = object.width
    data[:height] = object.height
    data[:weight] =  object.weight
    data[:description] =  object.description
    data[:price_cents] = object.price_cents
    data[:currency] = object.currency
    data[:commission] = commission_from_seller
    data[:delivery_methods] = delivery_methods
    data[:listing_images] = listing_images
    data[:origin] = object.origin
    data[:location] = object.location
    data[:category] = category
    data[:subcategory] = subcategory
    data[:custom_fields] = custom_fields
    return data
  end

  def category
    category = object.category.parent.present? ? object.category.parent : object.category
      {id: category.id,
       name: category.display_name('en'),
       url: category.url,
       parent_id: category.parent_id,
       is_parent: category.children.blank? ? false : true
      }
  end

  def subcategory
    if object.category.parent.present? 
      subcategory = {id: object.category.id,
       name: object.category.display_name('en'),
       url: object.category.url,
       parent_id: object.category.parent_id,
       is_parent: object.category.children.blank? ? false : true
      }
      return subcategory 
    else
      return {}
    end
  end

  def delivery_methods
    delivery_methods = []
    delivery_methods << "pickup" if object.pickup_enabled
    delivery_methods << "shipping" if object.length.present? && object.width.present? && object.height.present? && object.weight.present?
    return delivery_methods
  end

  def listing_images
    listing_images = []
    object.listing_images.each do |listing_image|
      listing_images << {id: listing_image.id, url: listing_image.image.url}
    end
    return listing_images    
  end

  # def dom
  #   dom = []
  #   dom << {"custom_fields[11][(1i)]" => ((Date.today.year - 20)..Date.today.year).to_a, "selected_option" => object.custom_field_value_for('DOM').present? ? object.custom_field_value_for('DOM').strftime("%Y") : nil}
  #   dom << {"custom_fields[11][(2i)]" => [['January', 1], ['February',2],['March', 3],['April', 4],['May', 5], ['june', 6],  ['july', 7], ['August', 8], ['September', 9], ['October', 10], ['November', 11], ['December', 12]],
  #           "selected_option" => object.custom_field_value_for('DOM').present? ? object.custom_field_value_for('DOM').strftime("%m") : nil
  #          }
  #   dom << {"custom_fields[11][(3i)]" => (1..31).to_a, "selected_option" => object.custom_field_value_for('DOM').present? ? object.custom_field_value_for('DOM').strftime("%d") : nil}
  #   return dom    
  # end

  def commission_from_seller
    ps = PaymentSettings.find_by(payment_gateway: "stripe")
    communityCommissionPercentage = ps.commission_from_seller
    minCommission = ps.minimum_transaction_fee_cents.present? ? (ps.minimum_transaction_fee_cents/100) : nil
    listing_price = object.price
    minCommission = minCommission || 0
    commission = (listing_price * communityCommissionPercentage / 100)
    commission = commission.fractional.present? ? commission.fractional/100 : 0
    return [commission, minCommission].max.to_f
  end

  def custom_fields
    custom_fields = []
    object.category.custom_fields.each do |custom_field|
      custom_fields << CustomFieldsForEditListingSerializer.new(custom_field, root: false, serializer_options: {category_id: object.category_id, listing_id: object.id})
    end
    return custom_fields    
  end
end
