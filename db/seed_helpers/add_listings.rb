
require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/listings'

def add_listings 
  Listing.all.each do |l|
    l.destroy 
  end
  listings.each do |listing|
    AddListings.submit_form(listing)
  end
end

class AddListings 
  extend Analytics
  def self.submit_form(p) 
    params = ActionController::Parameters.new(p)
    params["listing"].delete("origin_loc_attributes") if params["listing"]["origin_loc_attributes"]["address"].blank?
    
    shape = get_shape(Maybe(params)["listing"]["listing_shape_id"].to_i.or_else(nil))
    listing_uuid = UUIDUtils.create
  
    unless create_booking(shape, listing_uuid)
      flash[:error] = t("listings.error.create_failed_to_connect_to_booking_service")
      return redirect_to new_listing_path
    end
  
    result = ListingFormViewUtils.build_listing_params(shape, listing_uuid, params, Community.first)
  
    unless result.success
      return
    end
  
    @listing = Listing.new(result.data)
  
    ActiveRecord::Base.transaction do
      @listing.author = Person.first
  
      if @listing.save
        @listing.upsert_field_values!(params.to_unsafe_hash["custom_fields"])
        @listing.reorder_listing_images(params, Person.first.id)
        notify_about_new_listing(@listing)
  
      else
        logger.error("Errors in creating listing: #{@listing.errors.full_messages.inspect}")
      end
    end
  end
  
  def self.get_shape(listing_shape_id)
    Community.first.shapes.find(listing_shape_id)
  end
  
  def self.create_booking(shape, listing_uuid)
    if APP_CONFIG.harmony_api_in_use && shape.present? && shape[:availability] == 'booking'
      create_bookable(Community.first.uuid_object, listing_uuid, Person.first.uuid_object).success
    else
      true
    end
  end
  
  def self.notify_about_new_listing(listing)
    Delayed::Job.enqueue(ListingCreatedJob.new(listing.id, Community.first.id))
    if Community.first.follow_in_use?
      Delayed::Job.enqueue(NotifyFollowersJob.new(listing.id, Community.first.id), :run_at => NotifyFollowersJob::DELAY.from_now)
    end
  
    # Onboarding wizard step recording
    state_changed = Admin::OnboardingWizard.new(Community.first.id)
      .update_from_event(:listing_created, listing)
    if state_changed
      record_event({},"km_record", {km_event: "Onboarding listing created"}, AnalyticService::EVENT_LISTING_CREATED)
    end
  end
end