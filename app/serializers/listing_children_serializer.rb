class ListingChildrenSerializer < ActiveModel::Serializer
  
  def attributes
    data = super
    data[:container] = child_container_listing
    data[:main] = child_main_listing
    data[:reserve] = child_reserve_listing
    data[:add] = child_aad_listing
    return data
  end

  def child_container_listing
    child_container = object.child_container
    container_listing = listing_details(child_container)
    return {} unless container_listing
    container_listing
  end

  def child_main_listing
    child_main = object.child_main
    main_listing = listing_details(child_main)
    return {} unless main_listing
    main_listing
  end

  def child_reserve_listing
    child_reserve = object.child_reserve
    reserve_listing = listing_details(child_reserve)
    return {} unless reserve_listing
    reserve_listing
  end

  def child_aad_listing
    child_aad = object.child_aad
    aad_listing = listing_details(child_aad)
    return {} unless aad_listing
    aad_listing
  end

  def listing_details(listing)
    if listing.present?
      listing_details = {
        id: listing.id,
        title: listing.title,
        author_id: listing.author_id,
        language: listing.language,
        description: listing.description,
        origin: listing.origin,
        destination: listing.destination,
        valid_until: listing.valid_until,
        open: listing.open,
        comments_count: listing.comments_count,
        listing_shape_id: listing.listing_shape_id,
        transaction_process_id: listing.transaction_process_id,
        shape_name_tr_key: listing.shape_name_tr_key,
        action_button_tr_key: listing.action_button_tr_key,
        price_cents: listing.price_cents,
        currency: listing.currency,
        quantity: listing.quantity,
        unit_type: listing.unit_type,
        deleted: listing.deleted,
        require_shipping_address: listing.require_shipping_address,
        pickup_enabled: listing.pickup_enabled,
        shipping_price_cents: listing.shipping_price_cents,
        shipping_price_additional_cents: listing.shipping_price_additional_cents,
        product_id: listing.product_id,
        known_manufacturer: listing.known_manufacturer,
        known_model: listing.known_model,
        known_size: listing.known_size,
        known_container_size: listing.known_container_size,
        known_harness_size: listing.known_harness_size,
        parent_id: listing.parent_id,
        sold: listing.sold,
        length: listing.length,
        width: listing.width,
        height: listing.height,
        weight: listing.weight,
        delete_note: listing.delete_note,
        willing_to_piece: listing.willing_to_piece,
        listing_images: listing_images(listing),
        custom_fields: custom_fields(listing),
        view_info: false
      }
      return listing_details  
    end  
  end

private

  def custom_fields(listing)
    custom_fields = []
    unless listing.custom_field_values.blank?
      listing.custom_field_values.each do |custom_field_value|
        custom_field_value.with_type do |question_type|
          if question_type == :text
            custom_fields << {label: custom_field_value.question.name(I18n.locale), value: custom_field_value.text_value}
          elsif question_type == :numeric
            custom_fields << {label: custom_field_value.question.name(I18n.locale), value: custom_field_value.display_value}
          elsif question_type == :dropdown
            custom_fields << {label: custom_field_value.question.name(I18n.locale), value: custom_field_value.selected_options&.first&.title(I18n.locale)}
          elsif question_type == :date_field
            custom_fields << {label: custom_field_value.question.name(I18n.locale), value: custom_field_value.date_value}
          end
        end
      end
    end
    return custom_fields
  end 

  def listing_images(listing)
    listing_images_url = []
    unless listing.listing_images.blank?
      listing.listing_images.each do |listing_image|
        listing_images_url = {id: listing_image.id, url: listing_image.image.url}
      end
    end
    return listing_images_url   
  end   
end
