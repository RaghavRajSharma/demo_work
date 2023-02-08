class FacebookService 
  def initialize(params)
    @access_token = params[:access_token]
    @graph = Koala::Facebook::API.new(@access_token, Community.first.facebook_connect_secret)
    @profile = @graph.get_object("me")
    @friends = @graph.get_connections("me", "friends")
  end

  def friends
    @friends
  end

  def graph
    @graph
  end

  # def mutual_friends(other_id)
  #   @graph.get_object(other_id, {fields: ["context.fields(all_mutual_friends)"]}) { |data| data["context"]["all_mutual_friends"]["data"] }
  # end

  def mutual_friends(other_user_token)
    other_user_graph = Koala::Facebook::API.new(other_user_token, Community.first.facebook_connect_secret)
    listing_author_friends = other_user_graph.get_connections("me", "friends")
    common_friends = friends & listing_author_friends
    common_friends.each do |f|
      person = Person.find_by(facebook_id: f["id"])
      f[:image]= @graph.get_picture(f["id"])
      f[:flyingflea_username] = person&.username
    end
    common_friends
  rescue
    []
  end

  def mutual_friend_thumbnails(other_id)
    mutual_friends(other_id).map do |f|
      f["picture"]["data"]["url"]
    end
  end
end