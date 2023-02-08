class ListingCommentSerializer < ActiveModel::Serializer
  attributes :id, :author_id, :listing_id, :content, :created_at, :comment_author

  def comment_author
    author_detail = { 
      comment_author_id: object.author_id,
      name: PersonViewUtils.person_display_name(object.author, object.author.community),
      image: object.author.image.present? ? object.author.image.url(:thumb) : "https://theflyingflea.com/assets/profile_image/thumb/missing.png"
    }
    return author_detail 
  end
end
