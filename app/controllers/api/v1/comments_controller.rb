class Api::V1::CommentsController < Api::V1::BaseController
  swagger_controller :comments, 'comments'

  swagger_api :create do
    summary "create comments"
    notes "Creates comments for listing"
    param :form, "listing_id", :integer, :required, "Listing Id."
    param :form, "content", :string, :required, "Content of feedback"
    param :form, "author_follow_status", :boolean, :optional, "Checkbox values in True or False"
    param :form, "author_id", :string, :required, "Id of author"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end 

  swagger_api :destroy do
    summary "delete comments"
    notes "Author can delete comments"
    param :form, "listing_id", :integer, :required, "Listing Id."
    param :form, "author_id", :string, :required, "Id of author"
    param :form, "comment_id", :integer, :required, "comment's id."
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end      

  def create
    if params[:content].present? && (params[:author_id].present? && params[:listing_id])
      author = Person.find_by(id: params[:author_id])
      listing = Listing.find_by(id: params[:listing_id])
      if author.present?
        if listing.present?
          comment = listing.comments.new(author_id: author.id, content: params[:content], author_follow_status: params[:author_follow_status],community_id: current_community.id)
          if comment.save
            Delayed::Job.enqueue(CommentCreatedJob.new(comment.id, current_community.id))
            render json: listing&.comments, each_serializer: ListingCommentSerializer, status: 200
          else
            render json: {error: "Something went wrong,please try later!"}, status: 404
          end
        else
          render json: {error: "Listing not found!"}, status: 404
        end  
      else
        render json: {error: "Invalid author!"}, status: 404
      end
    else
      render json: {error: "Invalid parameter!"}, status: 404
    end
  end

  def destroy
    if params[:listing_id].present? && (params[:author_id].present? && params[:comment_id].present?)
      listing = Listing.find_by(id: params[:listing_id])
      comment = current_community.listings.find(params[:listing_id]).comments.find(params[:comment_id])
      if comment.present?
        author = Person.find_by(id: params[:author_id])
        if author == comment.author || author.has_admin_rights?(current_community)
          if comment.destroy
            render json: listing&.comments, each_serializer: ListingCommentSerializer, status: 200
          else
            render json: {error: "Something went wrong, please try later."}, status: 404
          end
        else
          render json: {error: "you are not authorized to do this!"}, status: 404
        end
      else
        render json: {error: "Comment not found!"}, status: 404
      end
    else
      render json: {error: "Invalid parameter!"}, status: 404
    end
  end
end
