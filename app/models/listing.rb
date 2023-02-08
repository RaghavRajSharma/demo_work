# encoding: utf-8
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

class Listing < ApplicationRecord

  include ApplicationHelper
  include ActionView::Helpers::TranslationHelper
  include Rails.application.routes.url_helpers

  belongs_to :author, :class_name => "Person", :foreign_key => "author_id"
  belongs_to :product

  has_many :listing_images, -> { where("error IS NULL").order("position") }, :dependent => :destroy

  has_many :conversations
  has_many :comments, :dependent => :destroy
  has_many :custom_field_values, :dependent => :destroy
  has_many :custom_dropdown_field_values, :class_name => "DropdownFieldValue"
  has_many :custom_checkbox_field_values, :class_name => "CheckboxFieldValue"
  has_many :wishlists, dependent: :destroy

  has_one :location, :dependent => :destroy
  has_one :origin_loc, -> { where('location_type = ?', 'origin_loc') }, :class_name => "Location", :dependent => :destroy
  has_one :destination_loc, -> { where('location_type = ?', 'destination_loc') }, :class_name => "Location", :dependent => :destroy
  accepts_nested_attributes_for :origin_loc, :destination_loc

  has_and_belongs_to_many :followers, :class_name => "Person", :join_table => "listing_followers"

  belongs_to :category

  monetize :price_cents, :allow_nil => true, with_model_currency: :currency
  monetize :shipping_price_cents, allow_nil: true, with_model_currency: :currency
  monetize :shipping_price_additional_cents, allow_nil: true, with_model_currency: :currency

  before_validation :set_valid_until_time

  validates_presence_of :author_id
  validates_length_of :title, :in => 2..60, :allow_nil => false

  before_create :set_sort_date_to_now
  def set_sort_date_to_now
    self.sort_date ||= Time.now
  end

  before_create :set_updates_email_at_to_now
  def set_updates_email_at_to_now
    self.updates_email_at ||= Time.now
  end

  def uuid_object
    if self[:uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:uuid])
    end
  end

  def uuid_object=(uuid)
    self.uuid = UUIDUtils.raw(uuid)
  end

  before_create :add_uuid
  def add_uuid
    self.uuid ||= UUIDUtils.create_raw
  end

  before_validation do
    # Normalize browser line-breaks.
    # Reason: Some browsers send line-break as \r\n which counts for 2 characters making the
    # 5000 character max length validation to fail.
    # This could be more general helper function, if this is needed in other textareas.
    self.description = description.gsub("\r\n","\n") if self.description
  end
  validates_length_of :description, :maximum => 5000, :allow_nil => true
  validates_presence_of :category
  validates_inclusion_of :valid_until, :allow_nil => :true, :in => DateTime.now..DateTime.now + 7.months
  validates_numericality_of :price_cents, :only_integer => true, :greater_than_or_equal_to => 0, :message => "price must be numeric", :allow_nil => true

  def self.currently_open(status="open")
    status = "open" if status.blank?
    case status
    when "all"
      where([])
    when "open"
      where(["open = '1' AND (valid_until IS NULL OR valid_until > ?)", DateTime.now])
    when "closed"
      where(["open = '0' OR (valid_until IS NOT NULL AND valid_until < ?)", DateTime.now])
    end
  end

  def visible_to?(current_user, current_community)
    # DEPRECATED
    #
    # Consider removing the `visible_to?` method.
    #
    # Reason: Authorization logic should be in the controller layer (filters etc.),
    # not in the model layer.
    #
    ListingVisibilityGuard.new(self, current_community, current_user).visible?
  end

  def current_state
    return 'Sold' if sold?
    return 'Closed' if !open?
    'Open'
  end

  # sets the time to midnight
  def set_valid_until_time
    if valid_until
      self.valid_until = valid_until.utc + (23-valid_until.hour).hours + (59-valid_until.min).minutes + (59-valid_until.sec).seconds
    end
  end

  # Overrides the to_param method to implement clean URLs
  def to_param
    self.class.to_param(id, title)
  end

  def self.to_param(id, title)
    "#{id}-#{title.to_url}"
  end

  def self.find_by_category_and_subcategory(category)
    Listing.where(:category_id => category.own_and_subcategory_ids)
  end

  # Returns true if listing exists and valid_until is set
  def temporary?
    !new_record? && valid_until
  end

  def update_fields(params)
    update_attribute(:valid_until, nil) unless params[:valid_until]
    update_attributes(params)
  end

  def closed?
    !open? || (valid_until && valid_until < DateTime.now)
  end

  # Send notifications to the users following this listing
  # when the listing is updated (update=true) or a
  # new comment to the listing is created.
  def notify_followers(community, current_user, update)
    followers.each do |follower|
      unless follower.id == current_user.id
        if update
          MailCarrier.deliver_now(PersonMailer.new_update_to_followed_listing_notification(self, follower, community))
        else
          MailCarrier.deliver_now(PersonMailer.new_comment_to_followed_listing_notification(comments.last, follower, community))
        end
      end
    end
  end

  def image_by_id(id)
    listing_images.find_by_id(id)
  end

  def prev_and_next_image_ids_by_id(id)
    listing_image_ids = listing_images.collect(&:id)
    ArrayUtils.next_and_prev(listing_image_ids, id);
  end

  def has_image?
    !listing_images.empty?
  end

  def icon_name
    category.icon_name
  end

  # The price symbol based on this listing's price or community default, if no price set
  def price_symbol
    price ? price.symbol : MoneyRails.default_currency.symbol
  end

  def answer_for(custom_field)
    custom_field_values.find { |value| value.custom_field_id == custom_field.id }
  end

  def unit_type
    Maybe(read_attribute(:unit_type)).to_sym.or_else(nil)
  end

  def init_origin_location(location)
    if location.present?
      build_origin_loc(location.attributes)
    else
      build_origin_loc()
    end
  end

  def ensure_origin_loc
    build_origin_loc unless origin_loc
  end

  def custom_field_value_factory(custom_field_id, answer_value)
    question = CustomField.find(custom_field_id)

    answer = question.with_type do |question_type|
      case question_type
      when :dropdown
        option_id = answer_value.to_i
        answer = DropdownFieldValue.new
        answer.custom_field_option_selections = [CustomFieldOptionSelection.new(:custom_field_value => answer,
                                                                                :custom_field_option_id => option_id,
                                                                                :listing_id => self.id)]
        answer
      when :text
        answer = TextFieldValue.new
        answer.text_value = answer_value
        answer
      when :numeric
        answer = NumericFieldValue.new
        answer.numeric_value = ParamsService.parse_float(answer_value)
        answer
      when :checkbox
        answer = CheckboxFieldValue.new
        answer.custom_field_option_selections = answer_value.map { |value|
          CustomFieldOptionSelection.new(:custom_field_value => answer, :custom_field_option_id => value, :listing_id => self.id)
        }
        answer
      when :date_field
        answer = DateFieldValue.new
        if answer_value["(1i)"].present?
          answer.date_value = Time.utc(answer_value["(1i)"].to_i,
                                     answer_value["(2i)"].to_i,
                                     answer_value["(3i)"].to_i)
        elsif answer_value.present?
          answer.date_value = answer_value
        end
   
        answer
      else
        raise ArgumentError.new("Unimplemented custom field answer for question #{question_type}")
      end
    end

    answer.question = question
    answer.listing_id = self.id
    return answer
  end

  # Note! Requires that parent self is already saved to DB. We
  # don't use association to link to self but directly connect to
  # self_id.
  def upsert_field_values!(custom_field_params)
    custom_field_params ||= {}

    # Delete all existing
    custom_field_value_ids = self.custom_field_values.map(&:id)
    CustomFieldOptionSelection.where(custom_field_value_id: custom_field_value_ids).delete_all
    CustomFieldValue.where(id: custom_field_value_ids).delete_all

    field_values = custom_field_params.map do |custom_field_id, answer_value|
      custom_field_value_factory(custom_field_id, answer_value) unless is_answer_value_blank(answer_value)
    end.compact

    # Insert new custom fields in a single transaction
    CustomFieldValue.transaction do
      field_values.each(&:save!)
    end
  end

  def is_answer_value_blank(value)
    if value.is_a?(Hash)
      value["(3i)"].blank? || value["(2i)"].blank? || value["(1i)"].blank?  # DateFieldValue check
    else
      value.blank?
    end
  end

  def reorder_listing_images(params, user_id)
    listing_image_ids =
      if params[:listing_images]
        params[:listing_images].collect { |h| h[:id] }.select { |id| id.present? }
      else
        logger.error("Listing images array is missing", nil, {params: params})
        []
      end
    ListingImage.where(id: listing_image_ids, author_id: user_id).update_all(listing_id: self.id)

    if params[:listing_ordered_images].present?
      params[:listing_ordered_images].split(",").each_with_index do |image_id, position|
        ListingImage.where(id: image_id, author_id: user_id).update_all(position: position+1)
      end
    end
  end

  ########################## Flying Flea Customizations ##########################

  has_many :children, class_name: 'Listing', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Listing', foreign_key: 'parent_id'

  after_commit :check_for_known_product

  def check_for_known_product
    manufacturer_id = CustomField.joins(:names).where("custom_field_names.value = 'Manufacturer'").first.id if manufacturer_id = CustomField.joins(:names).where("custom_field_names.value = 'Manufacturer'").first
    model_id = CustomField.joins(:names).where("custom_field_names.value = 'Model'").first.id if CustomField.joins(:names).where("custom_field_names.value = 'Model'").first
    return unless manufacturer_id
    manufacturer = self.custom_field_values.find_by(custom_field_id: manufacturer_id).text_value if self.custom_field_values.find_by(custom_field_id: manufacturer_id)
    if Product.find_by(manufacturer: manufacturer)
      self.known_manufacturer = true
      model = self.custom_field_values.find_by(custom_field_id: model_id).text_value if self.custom_field_values.find_by(custom_field_id: model_id)
      product = Product.find_by(manufacturer: manufacturer, model: model) if manufacturer && model
      if self.category.translations.find_by(locale: 'en') && self.category.translations.find_by(locale: 'en').name == "Containers"
        if product
          self.product = product
          self.known_model = true
          container_size_id = CustomField.joins(:names).where("custom_field_names.value = 'Container Size'").first.id
          container_size = self.custom_field_values.find_by(custom_field_id: container_size_id).text_value if self.custom_field_values.find_by(custom_field_id: container_size_id)
          if container_size && product.options_for('Container Size').include?(container_size)
            self.known_container_size = true
          else
            self.known_container_size = false
          end
          # if product.options_for('Harness Size').include?(harness_size)
          #   self.known_harness_size = true
          # else
          #   self.known_harness_size = false
          # end
        else
          self.known_model = false
          self.known_container_size = false
          # self.known_harness_size = false
        end
      else
        if product
          self.product = product
          self.known_model = true
          size_field = CustomField.joins(:names).where("custom_field_names.value = 'Size'").first
          size_id = size_field.id if size_field
          size_value = self.custom_field_values.find_by(custom_field_id: size_id)
          size = size_value.text_value if size_value
          if size && product.options_for('size').include?(size)
            self.known_size = true
          else
            self.known_size = false
          end
        else
          self.known_model = false
          self.known_size = false
        end
      end
    end

  end

  def logger
    @logger ||= SharetribeLogger.new(:listing, logger_metadata.keys).tap { |logger|
      logger.add_metadata(logger_metadata)
    }
  end

  def logger_metadata
    { listing_id: id }
  end

  def is_multi_listing?
    self.category.is_multi_listing?
  end

  def is_child?
    !!self.parent
  end

  def can_be_edited_by?(user)
    self.author == user
  end

  def is_full_rig?
    self.category.is_full_rig?
  end

  def is_partial_rig?
    self.category.is_partial_rig?
  end

  def child_container
    children.find_by(category: Category.find_by_name("Containers"))
  end

  def child_main
    children.find_by(category: Category.find_by_name("Main"))
  end

  def child_reserve
    children.find_by(category: Category.find_by_name("Reserve"))
  end

  def child_aad
    children.find_by(category: Category.find_by_name("AADs"))
  end

  def is_complete_full_rig?
    !!(child_container && child_main && child_reserve)
  end

  def listing_open_close_for_complete_rig
    if self.category.display_name('en').eql?("Complete Rigs")
      self.is_complete_full_rig? ? self.update_attribute(:open, true) : self.update_attribute(:open, false)
    end
  end

  def is_complete_partial_rig?
    !!(child_container && (child_main || child_reserve))
  end

  def new_child=(id)
    child = Listing.find_by_id(id)
    if child
      self.children << child
    end
  end
  def new_child

  end

  def mark_sold
    self.sold = true
    self.save
  end

  def unmark_sold
    self.sold = false
    self.save
  end

  def mark_closed
    self.open = false
    self.save
  end

  def color
    dropdown_field_value_for('Color')
  end

  def height_range
    dropdown_field_value_for('Height Range (optional)')
  end

  def weight_range
    dropdown_field_value_for('Weight Range (optional)')
  end

  def condition
    dropdown_field_value_for('Condition')
  end

  def secondary_color
    dropdown_field_value_for('Secondary Color (optional)')
  end

  def jump_number
    dropdown_field_value_for('Jump Number')
  end

  def ride_number
    dropdown_field_value_for('Ride Number')
  end

  def repack_number
    dropdown_field_value_for('Repack Number')
  end

  def aad_ready
    dropdown_field_value_for('AAD ready?')
  end

  def rsl
    dropdown_field_value_for('RSL?')
  end

  def lines
    dropdown_field_value_for('Lines')
  end

  def lineset_jump_number
    dropdown_field_value_for('Lineset Jump Number')
  end

  def patches
    dropdown_field_value_for('Patches? (optional)')
  end

  def fired
    dropdown_field_value_for('Fired?')
  end

  def original_owner
    dropdown_field_value_for('Original Owner? (optional)')
  end

  def serial_number
    custom_field_value_for('Serial #')
  end

  def dom
    custom_field_value_for('DOM')
  end

  def last_service_date
    custom_field_value_for('Last Service Date')
  end

  def custom_fields
    [{label: 'Color', value: color}, {label: 'Height Range (optional)', value: height_range}, 
      {label: 'Weight Range (optional)', value: weight_range}, {label: 'Condition', value: condition}, 
      {label: 'Secondary Color (optional)', value: secondary_color}, {label: 'Jump Number', value: jump_number}, 
      {label: 'Ride Number', value: ride_number}, {label: 'Repack Number', value: repack_number}, 
      {label: 'AAD ready?', value: aad_ready}, {label: 'RSL?', value: rsl}, {label: 'Lines', value: lines},
      {label: 'Lineset Jump Number', value: lineset_jump_number}, {label: 'Patches? (optional)', value: patches},
      {label: 'Fired?', value: fired}, {label: 'Original Owner? (optional)', value: original_owner},
      {label: 'Serial #', value: serial_number}, {label: 'DOM', value: dom}, 
      {label: 'Last Service Date', value: last_service_date}]
  end

  def custom_field_value_for(name)
    custom_field = CustomField.find{|c| c.name == name}
    return unless custom_field
    answer = answer_for(custom_field)
    return unless answer
    case answer.type
    when "TextFieldValue"
      answer.text_value
    when "NumericFieldValue"
      answer.numeric_value
    when "DateFieldValue"
      answer.date_value
    end
  end

  def dropdown_field_value_for(name)
    custom_value = custom_value_field(name)
    return if custom_value.nil? || custom_value.try(:selected_options).try(:empty?)
    custom_value.selected_options.first&.title(I18n.locale)
    # custom_value.selected_options.first&.id
  end

  def custom_value_field(name)
    custom_field = CustomField.find{|c| c.name == name}
    return unless custom_field
    CustomFieldValue.find_by(custom_field_id: custom_field.id, listing_id: id)
  end


end
