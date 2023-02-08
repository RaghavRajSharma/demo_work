
require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/community_config'

def community_config 
  config.each do |option|
    CommunityConfig.send(option["method"], option["params"]) if CommunityConfig.respond_to?(option["method"])
  end
  tasks_complete = MarketplaceSetupSteps.first
  tasks_complete.cover_photo = true
  tasks_complete.invitation = true 
  tasks_complete.save
end

class CommunityConfig 
  extend Analytics

  def self.test(params)
    puts "params from inside the test"
  end

  def self.update_layout(p)
    params = ActionController::Parameters.new(p)
    h_params = params.to_unsafe_hash
    @community = Community.first
    enabled_for_user = Maybe(h_params[:enabled_for_user]).map { |f| NewLayoutViewUtils.enabled_features(f) }.or_else([])
    disabled_for_user = NewLayoutViewUtils.resolve_disabled(enabled_for_user)
  
    enabled_for_community = Maybe(h_params[:enabled_for_community]).map { |f| NewLayoutViewUtils.enabled_features(f) }.or_else([])
    disabled_for_community = NewLayoutViewUtils.resolve_disabled(enabled_for_community)
  
    response = update_feature_flags(community_id: @community.id, person_id: Person.first.id,
                                    user_enabled: enabled_for_user, user_disabled: disabled_for_user,
                                    community_enabled: enabled_for_community, community_disabled: disabled_for_community)
  
  end
  
  def self.update_feature_flags(community_id:, person_id:, user_enabled:, user_disabled:, community_enabled:, community_disabled:)
    updates = []
    updates << ->() {
      FeatureFlagService::API::Api.features.enable(community_id: community_id, person_id: person_id, features: user_enabled)
    } unless user_enabled.blank?
    updates << ->(*) {
      FeatureFlagService::API::Api.features.disable(community_id: @community.id, person_id: Person.first.id, features: user_disabled)
    } unless user_disabled.blank?
    updates << ->(*) {
      FeatureFlagService::API::Api.features.enable(community_id: @community.id, features: community_enabled)
    } unless community_enabled.blank?
    updates << ->(*) {
      FeatureFlagService::API::Api.features.disable(community_id: @community.id, features: community_disabled)
    } unless community_disabled.blank?
  
    Result.all(*updates)
  end

  def self.update_look_and_feel(p)
    params = ActionController::Parameters.new(p)
    @community = Community.first
    @selected_left_navi_link = "tribe_look_and_feel"
    analytic = AnalyticService::CommunityLookAndFeel.new(user: Person.first, community: @community)

    params[:community][:custom_color1] = nil if params[:community][:custom_color1] == ""
    params[:community][:custom_color2] = nil if params[:community][:custom_color2] == ""
    params[:community][:description_color] = nil if params[:community][:description_color] == ""
    params[:community][:slogan_color] = nil if params[:community][:slogan_color] == ""

    permitted_params = [
      :wide_logo, :logo,:cover_photo, :small_cover_photo, :favicon, :custom_color1,
      :custom_color2, :slogan_color, :description_color, :default_browse_view, :name_display_type
    ]
    permitted_params << :custom_head_script
    community_params = params.require(:community).permit(*permitted_params)
    analytic.process(Community.first, community_params)

    update(Community.first,
           community_params) { |community|
      analytic.send_properties
      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(community.id)
        .update_from_event(:community_updated, community)
    }
  end

  def self.update(model, params, &block)
    if model.update_attributes(params)
      block.call(model) if block_given? #on success, call optional block
    end
  end

  def self.update_details(p)
    params = ActionController::Parameters.new(p)
    update_results = []
    analytic = AnalyticService::CommunityCustomizations.new(user: Person.first, community: Community.first)

    customizations = Community.first.locales.map do |locale|
      permitted_params = [
        :name,
        :slogan,
        :description,
        :search_placeholder,
        :transaction_agreement_label,
        :transaction_agreement_content
      ]
      locale_params = params.require(:community_customizations).require(locale).permit(*permitted_params)
      customizations = find_or_initialize_customizations_for_locale(locale)
      customizations.assign_attributes(locale_params)
      analytic.process(customizations)
      update_results.push(customizations.update_attributes({}))
      customizations
    end

    process_locales = unofficial_locales.blank?

    if process_locales
      enabled_locales = params[:enabled_locales]
      all_locales = MarketplaceService::API::Marketplaces.all_locales.map{|l| l[:locale_key]}.to_set
      enabled_locales_valid = enabled_locales.present? && enabled_locales.map{ |locale| all_locales.include? locale }.all?
      if enabled_locales_valid
        MarketplaceService::API::Marketplaces.set_locales(Community.first, enabled_locales)
      end
    end

    transaction_agreement_checked = Maybe(params)[:community][:transaction_agreement_checkbox].is_some?
    update_results.push(Community.first.update_attributes(transaction_agreement_in_use: transaction_agreement_checked))

    analytic.send_properties
    if update_results.all? && (!process_locales || enabled_locales_valid)

      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(Community.first.id)
        .update_from_event(:community_customizations_updated, customizations)
    end
  end

  def self.find_or_initialize_customizations_for_locale(locale)
    Community.first.community_customizations.find_by_locale(locale) || build_customization_with_defaults(locale)
  end

  def self.build_customization_with_defaults(locale)
    Community.first.community_customizations.build(
      slogan: Community.first.slogan,
      description: Community.first.description,
      search_placeholder: t("homepage.index.what_do_you_need", locale: locale),
      locale: locale
    )
  end

  def self.unofficial_locales
    all_locales = MarketplaceService::API::Marketplaces.all_locales.map{|l| l[:locale_key]}
    Community.first.locales.select { |locale| !all_locales.include?(locale) }
      .map { |unsupported_locale_key|
        unsupported_locale_name = Sharetribe::AVAILABLE_LOCALES.select { |l| l[:ident] == unsupported_locale_key }.map { |l| l[:name] }.first
        {key: unsupported_locale_key, name: unsupported_locale_name}
      }
  end

  def self.send_invitations(p)
    params = ActionController::Parameters.new(p)
    invitation_params = params.require(:invitation).permit(
      :email,
      :message
    )

    raw_invitation_emails = invitation_params[:email].split(",").map(&:strip)
    invitation_emails = Invitation::Unsubscribe.remove_unsubscribed_emails(Community.first, raw_invitation_emails)

    sending_problems = nil
    invitation_emails.each do |email|
      invitation = Invitation.new(
        message: invitation_params[:message],
        email: email,
        inviter: Person.first,
        community_id: Community.first.id
      )

      if invitation.save
        Delayed::Job.enqueue(InvitationCreatedJob.new(invitation.id, Community.first.id))

        # Onboarding wizard step recording
        state_changed = Admin::OnboardingWizard.new(Community.first.id)
          .update_from_event(:invitation_created, invitation)
        if state_changed
          record_event({}, "km_record", {km_event: "Onboarding invitation created"}, AnalyticService::EVENT_USER_INVITED)
        end
      else
        sending_problems = true
      end
    end
  end

  def self.validate_daily_limit(inviter_id, number_of_emails, community)
    email_count = (number_of_emails + daily_email_count(inviter_id))
    email_count < Invitation.invitation_limit || (community.join_with_invite_only && email_count < Invitation.invite_only_invitation_limit)
  end

  def self.daily_email_count(inviter_id)
    Invitation.where(inviter_id: inviter_id, created_at: 1.day.ago..Time.now).count
  end

  def self.update_settings(p)
    params = ActionController::Parameters.new(p)
    @selected_left_navi_link = "settings"
    
    permitted_params = [
      :join_with_invite_only,
      :users_can_invite_new_users,
      :private,
      :require_verification_to_post_listings,
      :show_category_in_listing_list,
      :show_listing_publishing_date,
      :listing_comments_in_use,
      :automatic_confirmation_after_days,
      :automatic_newsletters,
      :default_min_days_between_community_updates,
      :email_admins_about_new_members
    ]
    settings_params = params.require(:community).permit(*permitted_params)

    maybe_update_payment_settings(Community.first.id, params[:community][:automatic_confirmation_after_days])

    if(FeatureFlagHelper.location_search_available)
      MarketplaceService::API::Api.configurations.update({
        community_id: Community.first.id,
        configurations: {
          main_search: params[:main_search],
          distance_unit: params[:distance_unit],
          limit_search_distance: params[:limit_distance].present?
        }
      })
    end

    update(Community.first,
            settings_params,
            )
  end

  def self.maybe_update_payment_settings(community_id, automatic_confirmation_after_days)
    return unless automatic_confirmation_after_days

    p_set = Maybe(payment_settings_api.get(
                   community_id: community_id,
                   payment_gateway: :paypal,
                   payment_process: :preauthorize))
            .map {|res| res[:success] ? res[:data] : nil}
            .or_else(nil)

    payment_settings_api.update(p_set.merge({confirmation_after_days: automatic_confirmation_after_days.to_i})) if p_set

    p_set = Maybe(payment_settings_api.get(
                   community_id: community_id,
                   payment_gateway: :stripe,
                   payment_process: :preauthorize))
            .map {|res| res[:success] ? res[:data] : nil}
            .or_else(nil)

    payment_settings_api.update(p_set.merge({confirmation_after_days: automatic_confirmation_after_days.to_i})) if p_set
  end
end

