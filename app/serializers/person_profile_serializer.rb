class PersonProfileSerializer < ActiveModel::Serializer
  attributes :id, 
            :api_token, 
            :email, 
            :given_name, 
            :family_name, 
            :username, 
            :full_name, 
            :display_name,
            :about,
            :image_url,
            :is_admin,
            :is_following,
            :listings,
            :wishlist_listings,
            :feedbacks,
            :profile_details,
            :show_more_listings

  has_many :followed_people

  def about
    object.description
  end

  def show_more_listings
    object.listings.currently_open.count > 6 rescue false
  end

  def full_name
    object.full_name
  end

  def display_name
    PersonViewUtils.person_display_name(object, object.community)
  end

  def email
    object.primary_email.address
  end

  def listings
    search = {
          author_id: object.id,
          include_closed: false,
          page: 1,
          per_page: 6
        }
      includes = [:author, :listing_images]
    ListingIndexService::API::Api
      .listings
      .search(
        community_id: current_community.id,
        search: search,
        engine: FeatureFlagHelper.search_engine,
        raise_errors: false,
        includes: includes
      ).and_then { |res|
      Result::Success.new(
        ListingIndexViewUtils.to_struct(
        result: res,
        includes: includes,
        page: search[:page],
        per_page: search[:per_page]
      ))
    }.data
  end

  def image_url
    return 'https://theflyingflea.com/assets/profile_image/medium/missing.png' unless object.image.exists?
    object.image.url(:medium)
  end

  def is_admin
    object.has_admin_rights?(current_community)
  end

  def feedbacks
    feedbacks = {
      postive_percent: object.feedback_positive_percentage_in_community(current_community),
      total_postive: TestimonialViewUtils.received_positive_testimonials_in_community(object, current_community).size,
      total_received: TestimonialViewUtils.received_testimonials_in_community(object, current_community).size,
      testimonials: testimonials
    }
    return feedbacks
  end

  def testimonials
    testimonials = TestimonialViewUtils.received_testimonials_in_community(object, current_community)
    results = []
    testimonials.each do |testimonial|
      results << {
        id: testimonial.id,
        text: testimonial.text,
        grade: testimonial.grade,
        author_id: testimonial.author_id,
        author_image_url: testimonial.author.image.url(:thumb),
        author_username: testimonial.author.username,
        author_display_name: PersonViewUtils.person_display_name(testimonial.author, current_community),
        listing_id: testimonial.tx.listing.id,
        listing_title: testimonial.tx.listing.title,
        last_activity: ApplicationController.helpers.time_ago(testimonial.created_at)
      }
    end
    return results
  end

  def profile_details
    {
      "Jump #:" => object.jump_number,
      "Association:" => object.membership_association,
      "Membership #:" => object.membership_number,
      "License Type:" => object.license_type,
      "License Number:" => object.license_number,
      "Rating(s):" => object.ratings.pluck(:name).join(', '),
      "Profession:" => object.profession,
      "Favorite Discipline:" => object.favorite_discipline&.name,
      "Other Disciplines(s):" => object.disciplines.pluck(:name).join(', '),
      "Home Drop Zone:" => object.home_dropzone&.name,
      "Other Drop Zone(s):" => object.dropzones.pluck(:name).join(', '),
      "Jumping since:" => object.jumping_since
    }
  end

  def is_following
    @options[:current_user].follows?(object) rescue false
  end

  def wishlist_listings
    listings = object.wishlist_listings
    unless listings.blank?
      search = {
        listing_ids: listings.pluck(:id),
        per_page: 1000,
        page: 1,
        include_closed: false
      }

      includes = [:author, :listing_images]

      wishlist_listings = ListingIndexService::API::Api
        .listings
        .search(
          community_id: current_community.id,
          search: search,
          engine: FeatureFlagHelper.search_engine,
          raise_errors: false,
          includes: includes
        ).and_then { |res|
        Result::Success.new(
          ListingIndexViewUtils.to_struct(
          result: res,
          includes: includes,
          page: search[:page],
          per_page: search[:per_page]
        ))
      }.data
    else
      wishlist_listings = []
    end
    return wishlist_listings 
  end

  private

    def current_community
      @current_community ||= Community.last
    end

end
