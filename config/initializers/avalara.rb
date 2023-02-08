if APP_CONFIG.avalara_account_number
  Avalara.configure do |config|
    config.username = APP_CONFIG.avalara_account_number
    config.password = APP_CONFIG.avalara_license_key
    config.endpoint = APP_CONFIG.avalara_service_url
  end
end  