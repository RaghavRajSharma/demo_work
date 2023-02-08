class Api::V1::InfosController < Api::V1::BaseController
  helper_method :community_customization

  def how_to_use
    content = if community_customization && !community_customization.how_to_use_page_content.nil?
      community_customization.how_to_use_page_content.html_safe
    else
      MarketplaceService::API::Marketplaces::Helper.how_to_use_page_default_content(I18n.locale, current_community.name(I18n.locale))
    end
    render json: {message: 'ok', data: content}
  end

  def privacy
    content = community_customization.privacy_page_content.html_safe rescue nil
    render json: {message: 'ok', data: content}
  end

  def about
    content = community_customization.about_page_content.html_safe rescue nil
    render json: {message: 'ok', data: content}
  end

  def terms
    content = community_customization.terms_page_content.html_safe rescue nil
    render json: {message: 'ok', data: content}
  end

  private

    def community_customization
      @community_customization ||= current_community.community_customizations.where(locale: 'en').first
    end
end