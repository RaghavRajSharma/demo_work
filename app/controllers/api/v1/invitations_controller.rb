class Api::V1::InvitationsController < Api::V1::BaseController
  swagger_controller :invitations, 'Invitations'

  swagger_api :create do
    summary "Sends invitaions"
    notes "Allow person to send invitaions via emails and inviation message"
    param :form, :inviter_id, :string, :required, "Username of inviter"
    param :form, :emails, :string, :required, "Email to be invited."
    param :form, :message, :string, :required, "Invitation message"
    response :unauthorized
    response :not_acceptable
  end

  def create
    inviter = Person.find_by!(username: params[:inviter_id], community_id: current_community.id)
    if inviter.present?
      if params[:emails].present?
        raw_invitation_emails = params[:emails].split(",").map(&:strip)
        invitation_emails = Invitation::Unsubscribe.remove_unsubscribed_emails(current_community, raw_invitation_emails)
        unless validate_daily_limit(inviter.id, invitation_emails.size, current_community)
          render json: { error: t("layouts.notifications.invitation_limit_reached")}, status: 404
        end
        sending_problems = nil
        invitation_emails.each do |email|
          invitation = Invitation.new(
            message: params[:message],
            email: email,
            inviter: inviter,
            community_id: current_community.id
          )
          if invitation.save
            Delayed::Job.enqueue(InvitationCreatedJob.new(invitation.id, current_community.id))

            # Onboarding wizard step recording
            state_changed = Admin::OnboardingWizard.new(current_community.id)
              .update_from_event(:invitation_created, invitation)
            if state_changed
              record_event(flash, "km_record", {km_event: "Onboarding invitation created"}, AnalyticService::EVENT_USER_INVITED)

              flash[:show_onboarding_popup] = true
            end
          else
            sending_problems = true
          end
        end
        if sending_problems
          render json: {error: "invitation cannot be sent!"}, status: 404
        else
          render json: {success: "invitation sent successfully."}, status: 200
        end                                    
      else
        render json: {error: "Please enter emails to which invitaions will be sent."}, status: 404
      end  
    else
      render json: {error: "Inviter not found!"}, status: 404
    end
  end

private

  def validate_daily_limit(inviter_id, number_of_emails, community)
    email_count = (number_of_emails + daily_email_count(inviter_id))
    email_count < Invitation.invitation_limit || (community.join_with_invite_only && email_count < Invitation.invite_only_invitation_limit)
  end

  def daily_email_count(inviter_id)
    Invitation.where(inviter_id: inviter_id, created_at: 1.day.ago..Time.now).count
  end  
end
