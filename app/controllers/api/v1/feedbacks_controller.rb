class Api::V1::FeedbacksController < Api::V1::BaseController
  swagger_controller :feedbacks, 'Feedbacks'

  swagger_api :contact_us do
    summary "Contact us"
    notes "This creates a feedbacks for via contact us."
    param :form, "content", :string, :required, "Content of feedback"
    param :form, "author_id", :string, :required, "Id of author"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end  

  def contact_us
    if params[:content].present? && params[:author_id].present?
      author = Person.find_by(id: params[:author_id])
      if author.present?
        url = "http://theflyingflea.com/"
        email = Maybe(author).confirmed_notification_email_to.or_else(nil)
        feedback = Feedback.new(title: "", content: params[:content], url: url, author_id: author.id, email: email, community_id: current_community.id)
        if feedback.save
          MailCarrier.deliver_later(PersonMailer.new_feedback(feedback, current_community))
          render json: {success: "Your feedback submitted successfully."}, status: 200
        else
          render json: {error: "Something went wrong, please try later!"}, status: 404
        end
      else
        render json: {error: "Invalid author!"}, status: 404
      end
    else
      render json: {error: "Content and author_id field is required!"}, status: 404
    end
  end 
end
