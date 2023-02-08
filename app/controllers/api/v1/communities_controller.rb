class Api::V1::CommunitiesController < Api::V1::BaseController
  swagger_controller :communities, 'Communities'

  swagger_api :cover_photo do
    summary "Returns cover photo and logo of community"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def cover_photo
    community = {
      slogan: community_slogan,
      description: community_description,
      logo: {
        header: current_community.wide_logo.url(:header),
        header_highres: current_community.wide_logo.url(:header_highres)
      }
    }
    cover_photo = {
      cover_photo_url:  current_community.cover_photo.present? ? current_community.cover_photo.url(:original) : nil,
      small_cover_photo_url: current_community.small_cover_photo.present? ? current_community.small_cover_photo.url(:original) : nil,
      cover_enabled: current_community.cover_enabled
    }
    community.merge!(cover_photo)
    render json: {community: community}, status: 200
  end

  private
    def community_customization
      current_community.community_customizations.last
    end

    def community_slogan
      if community_customization  && !community_customization.slogan.blank?
        community_customization.slogan
      else
        if current_community.slogan && !current_community.slogan.blank?
          current_community.slogan
        else
          I18n.t("common.default_community_slogan")
        end
      end
    end

    def community_description(truncate=true)
      if community_customization && !community_customization.description.blank?
        truncate ? ApplicationController.helpers.truncate_html(community_customization.description, length: 140, omission: "...") : community_customization.description
      elsif current_community.description && !current_community.description.blank?
        truncate ? ApplicationController.helpers.truncate_html(current_community.description, length: 140, omission: "...") : current_community.description
      else
        truncate ? ApplicationController.helpers.truncate_html(I18n.t("common.default_community_description"), length: 125, omission: "...") : I18n.t("common.default_community_description")
      end
    end
end
