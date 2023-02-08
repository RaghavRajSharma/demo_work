class Api::V1::FollowersController < Api::V1::BaseController
  swagger_controller :followers, 'Followers'

  swagger_api :create do
    summary "creates followers of a person"
    notes "This end point creates followers of a person"
    param :form, :follower_id, :string, :required, "follower id as username of person"
    param :form, :following_id, :string, :required, "Username of person to be follow"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :destroy do
    summary "destroy followers of a person"
    notes "This end point destroy followers of a person"
    param :path, :id, :string, :required, "id of a username of follower"
    param :form, :following_id, :string, :required, "Username of person to be ufollow"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end     

  def create
    follower = Person.find_by!(username: params[:follower_id], community_id: current_community.id)
    to_be_follow  = Person.find_by!(username: params[:following_id], community_id: current_community.id)
    if follower.present? && to_be_follow.present?
      if follower == to_be_follow
        render json: {error: "You can not follow yourself!"}
      else
        to_be_follow.followers << follower
        render json: {success: "Followed successfully!"}, status: 200
      end
    else
      render json: {error: "follower or following person is missing!"}, status: 404
    end
  end

  def destroy
    follower = Person.find_by!(username: params[:id], community_id: current_community.id)
    to_be_unfollow  = Person.find_by!(username: params[:following_id], community_id: current_community.id)
    if follower.present? && to_be_unfollow.present?
      if follower == to_be_unfollow
        render json: {error: "You can not ufollow yourself!"}
      else
        to_be_unfollow.followers.delete(follower)
        render json: {success: "Unfollowed successfully!"}, status: 200
      end
    else
      render json: {error: "follower or Unfollowing person is missing!"}, status: 404
    end
  end  
end
