# == Schema Information
#
# Table name: listings
#
#  id                              :integer          not null, primary key
#  uuid                            :binary(16)       not null
#  community_id                    :integer          not null
#  author_id                       :string(255)
#  category_old                    :string(255)
#  title                           :string(255)
#  times_viewed                    :integer          default(0)
#  language                        :string(255)
#  created_at                      :datetime
#  updates_email_at                :datetime
#  updated_at                      :datetime
#  last_modified                   :datetime
#  sort_date                       :datetime
#  listing_type_old                :string(255)
#  description                     :text(65535)
#  origin                          :string(255)
#  destination                     :string(255)
#  valid_until                     :datetime
#  delta                           :boolean          default(TRUE), not null
#  open                            :boolean          default(TRUE)
#  share_type_old                  :string(255)
#  privacy                         :string(255)      default("private")
#  comments_count                  :integer          default(0)
#  subcategory_old                 :string(255)
#  old_category_id                 :integer
#  category_id                     :integer
#  share_type_id                   :integer
#  listing_shape_id                :integer
#  transaction_process_id          :integer
#  shape_name_tr_key               :string(255)
#  action_button_tr_key            :string(255)
#  price_cents                     :integer
#  currency                        :string(255)
#  quantity                        :string(255)
#  unit_type                       :string(32)
#  quantity_selector               :string(32)
#  unit_tr_key                     :string(64)
#  unit_selector_tr_key            :string(64)
#  deleted                         :boolean          default(FALSE)
#  require_shipping_address        :boolean          default(FALSE)
#  pickup_enabled                  :boolean          default(FALSE)
#  shipping_price_cents            :integer
#  shipping_price_additional_cents :integer
#  availability                    :string(32)       default("none")
#  product_id                      :integer
#  known_manufacturer              :boolean          default(FALSE)
#  known_model                     :boolean          default(FALSE)
#  known_size                      :boolean          default(FALSE)
#  known_container_size            :boolean          default(FALSE)
#  known_harness_size              :boolean          default(FALSE)
#  parent_id                       :integer
#  willing_to_piece                :boolean          default(TRUE)
#  sold                            :boolean          default(FALSE)
#  length                          :float(24)
#  width                           :float(24)
#  height                          :float(24)
#  weight                          :float(24)
#  delete_note                     :text(65535)
#  wishlists_count                 :integer          default(0)
#
# Indexes
#
#  homepage_query                      (community_id,open,sort_date,deleted)
#  homepage_query_valid_until          (community_id,open,valid_until,sort_date,deleted)
#  index_listings_on_category_id       (old_category_id)
#  index_listings_on_community_id      (community_id)
#  index_listings_on_listing_shape_id  (listing_shape_id)
#  index_listings_on_new_category_id   (category_id)
#  index_listings_on_open              (open)
#  index_listings_on_uuid              (uuid) UNIQUE
#  person_listings                     (community_id,author_id)
#  updates_email_listings              (community_id,open,updates_email_at)
#

class ListingSerializer < ActiveModel::Serializer
  attributes :id,
             :title, 
             :community_id,
             :author_id,
             :language,
             :description,
             :origin,
             :location,
             :destination,
             :valid_until,
             :open,
             :comments_count,
             :listing_shape_id,
             :transaction_process_id,
             :shape_name_tr_key,
             :action_button_tr_key,
             :price_cents,
             :currency,
             :quantity,
             :unit_type,
             :deleted,
             :require_shipping_address,
             :pickup_enabled,
             :shipping_price_cents,
             :shipping_price_additional_cents,
             :product_id,
             :known_manufacturer,
             :known_model,
             :known_size,
             :known_container_size,
             :known_harness_size,
             :parent_id,
             :willing_to_piece,
             :sold,
             :length,
             :width,
             :height,
             :weight,
             :delivery_methods,
             :delete_note,
             :listing_images,
             :custom_fields,
             :children,
             :postive_percent,
             :total_postive,
             :total_received


  # has_many :custom_field_values
  # has_many :custom_dropdown_field_values
  # has_many :custom_checkbox_field_values
  #has_many :children
  has_many :comments, :serializer => ListingCommentSerializer
  has_one  :author

  def location
    object.location.present? ? object.location : {}
  end

  def listing_images
    listing_images = []
    object.listing_images.each do |listing_image|
      listing_images << {id: listing_image.id, url: listing_image.image.url}
    end
    return listing_images
  end

  def custom_fields
    custom_fields = []
    unless object.custom_field_values.blank?
      object.custom_field_values.each do |custom_field_value|
        custom_field_value.with_type do |question_type|
          if question_type == :text
            custom_fields << {label: custom_field_value.question.name(I18n.locale), value: custom_field_value.text_value}
          elsif question_type == :numeric
            custom_fields << {label: custom_field_value.question.name(I18n.locale), value: custom_field_value.display_value}
          elsif question_type == :dropdown
            custom_fields << {label: custom_field_value.question.name(I18n.locale), value: custom_field_value.selected_options&.first&.title(I18n.locale)}
          elsif question_type == :date_field
            custom_fields << {label: custom_field_value.question.name(I18n.locale), value: custom_field_value.date_value.present? ? custom_field_value.date_value.strftime("%Y-%m-%d") : custom_field_value.date_value}
          end
        end
      end
    end
    return custom_fields
  end

  def children
    if object.is_multi_listing? 
      if object.is_full_rig?
        children = ListingChildrenSerializer.new(object, root: false)
      elsif object.is_partial_rig?
        children = ListingChildrenSerializer.new(object, root: false)
      end
    end
    return {} unless children
    children
  end
  
  def delivery_methods
    delivery_methods = []
    delivery_methods << "PickUp" if object.pickup_enabled
    delivery_methods << "Shipping" if object.length.present? && object.width.present? && object.height.present? && object.weight.present?
    return delivery_methods
  end
  
  def postive_percent
    return object.author.feedback_positive_percentage_in_community(current_community)
  end

  def total_postive
    return TestimonialViewUtils.received_positive_testimonials_in_community(object.author, current_community).size
  end

  def total_received
    return TestimonialViewUtils.received_testimonials_in_community(object.author, current_community).size
  end
  
  def current_community
    @current_community ||= Community.last
  end
end
