module ListingsHelper

  # Class is selected if conversation type is currently selected
  def get_map_tab_class(tab_name)
    current_tab_name = action_name || "map_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end

  # Removes extra characters from datetime_select field
  def clear_datetime_select(&block)
    time = "</div><div class='date_select_time_container'><div class='datetime_select_time_label'>#{t('listings.form.departure_time.at')}:</div>"
    colon = "</div><div class='date_select_time_container'><div class='datetime_select_colon_label'>:</div>"
    haml_concat capture_haml(&block).gsub(":", "#{colon}").gsub("&mdash;", "#{time}").gsub("\n", '').html_safe
  end

  # Class is selected if listing type is currently selected
  def get_listing_tab_class(tab_name)
    current_tab_name = params[:type] || "list_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end

  def listed_listing_title(listing)
    format_listing_title(listing.shape_name_tr_key, listing.title)
  end

  def format_listing_title(shape_tr_key, listing_title)
    listing_shape_name = t(shape_tr_key)
    # TODO remove this hotfix when we have admin ui for translations
    if listing_shape_name.include?("translation missing")
      listing_title
    else
      "#{listing_shape_name}: #{listing_title}"
    end
  end

  def localized_category_label(category)
    return nil if category.nil?
    return category.display_name(I18n.locale).capitalize
  end

  def localized_category_from_id(category_id)
    Maybe(category_id).map { |cat_id|
      Category.where(id: cat_id).first
    }.map { |category|
      category.display_name(I18n.locale).capitalize
    }.or_else(nil)
  end

  def localized_listing_type_label(listing_type_string)
    return nil if listing_type_string.nil?
    return t("listings.show.#{listing_type_string}", :default => listing_type_string.capitalize)
  end

  def listing_form_menu_titles()
    titles = {
      "category" => t("listings.new.select_category"),
      "subcategory" => t("listings.new.select_subcategory"),
      "listing_shape" => t("listings.new.select_transaction_type")
    }
  end

  def major_currencies(hash)
    hash.inject([]) do |array, (id, attributes)|
      array ||= []
      array << [attributes[:iso_code]]
      array.sort
    end.compact.flatten
  end

  def price_as_text(listing)
    MoneyViewUtils.to_humanized(listing.price) +
    unless listing.quantity.blank? then " / #{listing.quantity}" else "" end
  end

  def has_images?(listing)
    !listing.listing_images.empty?
  end

  def with_image_frame(listing, &block)
    if self.has_images?(listing) then
      images = listing.listing_images
      if !listing.listing_images.all? { |image| image.image_ready? } then
        block.call(:images_processing, nil)
      else
        block.call(:images_ok, images)
      end
    elsif listing.description.blank? then
      block.call(:no_description, nil)
    end
  end

  def with_quantity_text(community, listing, &block)
    buffer = []
    buffer.push(price_quantity_per_unit(listing))
    block.call(buffer.join(" ")) unless buffer.empty?
  end

  def price_quantity_slash_unit(listing)
    if listing.unit_type.present?
      "/ " + ListingViewUtils.translate_unit(listing.unit_type, listing.unit_tr_key)
    elsif listing.quantity.present?
      "/ #{listing.quantity}"
    else
      ""
    end
  end

  def price_quantity_per_unit(listing)
    quantity =
      if listing.unit_type.present?
        ListingViewUtils.translate_unit(listing.unit_type, listing.unit_tr_key)
      elsif listing.quantity.present?
        listing.quantity
      else
        nil
      end

    if quantity
      t("listings.show.price.per_quantity_unit", quantity_unit: quantity)
    else
      ""
    end
  end

  def shape_name(listing)
    t(listing.shape_name_tr_key)
  end

  def action_button_label(listing)
    t(listing.action_button_tr_key)
  end

  def new_willing_to_piece_link(listing, category_id=nil, subcategory_id=nil)
    params = {
      :willing_to_piece => 1,
      :parent_id => listing.id,
    }
    params[:category] = category_id if category_id
    params[:subcategory] = subcategory_id if subcategory_id
    link_to "Sell separately ", 
            "#{new_listing_path(params[:locale])}?#{params.to_query}",
            {style: 'padding: 0.5625em 1.5em; margin-top: 0.5625em; background-color: #7d00ba; color: white; border-radius: 5px',
             class: 'willing-to-piece'}
  end

  def new_not_willing_to_piece_link(listing, category_id=nil, subcategory_id=nil)
    params = {
      :willing_to_piece => 0,
      :parent_id => listing.id,
    }
    params[:category] = category_id if category_id
    params[:subcategory] = subcategory_id if subcategory_id
    link_to "Bundle only", 
            "#{new_listing_path(params[:locale])}?#{params.to_query}",
            {style: 'padding: 0.5625em 1.5em; margin-top: 0.5625em; background-color: #7d00ba; color: white; border-radius: 5px',
             class: 'not-willing-to-piece'}
  end

  def show_edit_options_for_child_listing(listing, category=nil)
    if @current_user && listing.can_be_edited_by?(@current_user)
      category_obj = Category.find_by_name(category)
      # find category_id and subcategory_id to pass to partial for use in helpers
      category_id = nil 
      subcategory_id = nil
      if category_obj 
        if category_obj.is_subcategory?
          category_id = category_obj.parent.id 
          subcategory_id = category_obj.id
        else 
          category_id = category_obj.id 
        end  
      end
      render :partial => "listings/add_items_buttons", locals: { :listing => listing, :category => category_id, :subcategory => subcategory_id }  
    end
  end

  def add_child_listings_to_multi_listing(listing, category_id=nil, subcategory_id=nil, type=nil)
    render :partial => "listings/add_child_listings_form", :locals => { :listing => listing, :category => category_id, :subcategory => subcategory_id }
  end

  def remove_child_listing_link(listing, type)
    if @current_user && listing.author == @current_user 
      link_to("Remove", '#', data: {url: remove_listing_from_rig_path(listing, listing.send("child_#{type}"), type)}, :class => 'remove-child', :id => "remove-#{listing.send("child_#{type}").category.id}")
    end
  end

  def parent_listing_link(listing)
    if listing.is_child?
      render :partial => "listings/parent_listing_link", :locals => { :parent => listing.parent }  
    end
  end

  def more_info_link(listing)
    render :partial => "listings/child_listings_more_info", :locals => { :listing => listing }
  end

  def sold_class(listing)
    obj = listing.is_a?(Listing) ? listing : Listing.find(listing.first.inspect)
    obj.sold ? "sold" : ""
  end

end
