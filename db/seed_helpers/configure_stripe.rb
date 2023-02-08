def configure_stripe 
  TransactionService::API::Api.processes.create(community_id: 1, process: :preauthorize, author_is_seller: true)
  TransactionService::API::Api.settings.provision( community_id: 1, payment_gateway: :stripe, payment_process: :preauthorize, active: true)
  FeatureFlagService::API::Api.features.enable(community_id: 1, features: [:stripe])
end

StripeApiKeysForm = FormUtils.define_form("StripeApiKeysForm",
  :api_private_key,
  :api_publishable_key).with_validations do
  validates_format_of :api_private_key, with: Regexp.new(APP_CONFIG.stripe_private_key_pattern)
  validates_format_of :api_publishable_key, with: Regexp.new(APP_CONFIG.stripe_publishable_key_pattern)
end

def process_update_stripe_keys
  api_form = StripeApiKeysForm.new(params[:stripe_api_keys_form])
  if api_form.valid? && api_form.api_private_key.present?
    if !@stripe_enabled
      tx_settings_api.provision({ community_id: @current_community.id,
                                  payment_process: :preauthorize,
                                  payment_gateway: :stripe,
                                  api_private_key: api_form.api_private_key,
                                  api_publishable_key: api_form.api_publishable_key
                                })
    else
      tx_settings_api.update({ community_id: @current_community.id,
                              payment_process: :preauthorize,
                              payment_gateway: :stripe,
                              api_private_key: api_form.api_private_key,
                              api_publishable_key: api_form.api_publishable_key
                              })
    end
    if stripe_api.check_balance(community: @current_community.id)
      tx_settings_api.api_verified(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize)
      tx_settings_api.activate(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize)
      flash[:notice] = t("admin.payment_preferences.stripe_verified")
    else
      tx_settings_api.disable(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize)
      flash[:error] = t("admin.payment_preferences.invalid_api_keys")
    end
  else
    flash[:error] = t("admin.payment_preferences.missing_api_keys")
  end
end

def stripe_api
  StripeService::API::Api.wrapper
end