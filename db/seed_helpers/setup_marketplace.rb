NewMarketplaceForm = Form::NewMarketplace

def setup_marketplace
    
  params = {
    :admin_email=>"theflyingfleamarket@gmail.com", 
    :admin_password=>"password", 
    :admin_first_name=>"Admin", 
    :admin_last_name=>"Test", 
    :marketplace_name=>"Flying Flea", 
    :marketplace_type=>"product", 
    :marketplace_country=>"US", 
    :marketplace_language=>"en", 
    :locale=>"en"
  }
  
  form = NewMarketplaceForm.new(params)
  
  if form.valid?
    form_hash = form.to_hash
    marketplace = MarketplaceService::API::Marketplaces.create(
      form_hash.slice(:marketplace_name,
                      :marketplace_type,
                      :marketplace_country,
                      :marketplace_language)
      .merge(payment_process: :none)
    )
  
    user = UserService::API::Users.create_user({
      given_name: form_hash[:admin_first_name],
      family_name: form_hash[:admin_last_name],
      email: form_hash[:admin_email],
      password: form_hash[:admin_password],
      locale: form_hash[:marketplace_language]},
      marketplace[:id]).data
  
    auth_token = UserService::API::AuthTokens.create_login_token(user[:id])
  end
end