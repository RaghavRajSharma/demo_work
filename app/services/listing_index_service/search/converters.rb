module ListingIndexService::Search::Converters
  module_function

  def listing_hash(l, includes, meta={})
    {
      id: l.id,
      title: l.title,
      description: l.description,
      updated_at: l.updated_at,
      created_at: l.created_at,
      category_id: l.category_id,
      comment_count: l.comments_count,
      price: l.price,
      unit_tr_key: l.unit_tr_key,
      unit_type: l.unit_type,
      quantity: l.quantity,
      shape_name_tr_key: l.shape_name_tr_key,
      listing_shape_id: l.listing_shape_id,
      category_name: l.category.display_name('en'),
      willing_to_piece: l.willing_to_piece,
      sold: l.sold
    }.merge(meta)
      .merge(location_hash(l, includes))
      .merge(author_hash(l, includes))
      .merge(listing_images_hash(l, includes))
  end

  def location_hash(l, includes)
    if true #includes.include?(:location)
      m_location = Maybe(l.location)
      {
        latitude: m_location.latitude.or_else(nil),
        longitude: m_location.longitude.or_else(nil),
        address: m_location.address.or_else(nil),
      }
    else
      {}
    end
  rescue
    {}
  end

  def author_hash(l, includes)
      if includes.include?(:num_of_reviews) || includes.include?(:author)
        {
          author: {
            id: l.author_id,
            username: l.author.username,
            first_name: l.author.given_name,
            last_name: l.author.family_name,
            display_name: l.author.display_name,
            avatar: {
              thumb: l.author.image.present? ? l.author.image.url(:thumb) : ApplicationController.helpers.image_path("profile_image/small/missing.png"),
            },
            is_deleted: l.author.deleted?,
            authentication_token: l.author.authentication_token,
          }.merge(num_of_reviews_hash(l, includes))
        }
      else
        {}
      end
  end

  def num_of_reviews_hash(l, includes)
    if includes.include?(:num_of_reviews)
      {num_of_reviews: l.author.received_testimonials.size}
    else
      {}
    end

  end

  def listing_images_hash(l, includes)
      if includes.include?(:listing_images)
        {
          listing_images: Maybe(l.listing_images.first)
            .select { |li| li.image_ready? } # Filter images that are not processed
            .map { |li|
              [{
                thumb: li.image.url(:thumb),
                small_3x2: li.image.url(:small_3x2),
                medium: li.image.url(:medium)
              }]
            }.or_else([])
        }
      else
        {}
      end
  end
end

