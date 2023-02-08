def config
  [
    {
      "method" => "test",
      "params" => {
        "key" => "value"
      }
    },
    {
      "method" => "update_layout",
      "params" => {
        "utf8"=>"✓", 

        "_method"=>"patch", 
        "authenticity_token"=>"Ym/fsWx7nCGD9B7z6RYAHUZfgcD1gAIUi4c1psJoqqdv/7e1GiSIJNRHDFtWb7aTH5uRlU5LMQ8J+AMG1rZwBw==", 
        "enabled_for_community"=>{"topbar_v1"=>"true"}, 
        "button"=>"", 
        "controller"=>"admin/communities", 
        "action"=>"update_new_layout", 
        "locale"=>"en"
      }
    },
    { 
      "method" => "update_look_and_feel",
      "params" => {
        "utf8"=>"✓", 
        "_method"=>"patch", 
        "authenticity_token"=>"Zio/+NFuCP+ZiFz0R5hvzzaFPK/JqOlmpjaDJdoel8hrulf8pzEc+s47Tlz44dlBb0Es+nJj2n0kSbWFzsBNaA==", 
        "community"=>{
          "custom_color1"=>"7d00ba", 
          "slogan_color"=>"", 
          "description_color"=>"", 
          "default_browse_view"=>"grid", 
          "name_display_type"=>"first_name_with_initial", 
          "custom_head_script"=>""
        }, 
        "button"=>"", 
        "controller"=>"admin/communities", 
        "action"=>"update_look_and_feel", 
        "locale"=>"en"
      }
    },
    {
      "method" => "update_details", 
      "params" => {
        "utf8"=>"✓", 
        "_method"=>"patch", 
        "authenticity_token"=>"PicT1XrPvJWSorEAPyPHGdpoYX9hvHbyunS+A2dp+lFMvRsOKnjw5BcrSjlB5vqFxTN+BdiS0oPuIumJblC1Vw==", 
        "enabled_locales"=>["en"], 
        "community_customizations"=>{
          "en"=>{
            "name"=>"Flying Flea", 
            "slogan"=>"Skydiving Gear for Sale & Wanted", 
            "description"=>"Buy and Sell New & Used Skydiving Gear ", 
            "search_placeholder"=>""
          }
        }, 
        "button"=>"", 
        "controller"=>"admin/community_customizations", 
        "action"=>"update_details", 
        "locale"=>"en"
      }
    },
    # {
    #   "method" => "send_invitations", 
    #   "params" => {
    #     "utf8"=>"✓", 
    #     "authenticity_token"=>"zClXt1YzTdhyN4h+t6YddkY00XWraJQUhA96xnfSYM76wtk4p2Ls6bKwU6J+dMbh1i5GbUGrIm9wa/w7T+Vd7w==", 
    #     "invitation"=>{
    #       "email"=>"shawnstern@gmail.com, dakotaleemusic@gmail.com", 
    #       "message"=>"This is so cool!!!"
    #     }, 
    #     "button"=>"", 
    #     "controller"=>"invitations", 
    #     "action"=>"create", 
    #     "locale"=>"en"
    #   }
    # },
    {
      "method" => "update_settings", 
      "params" => {
        "utf8"=>"✓", 
        "_method"=>"patch", 
        "authenticity_token"=>"2eUIcRlEasa53cJ1S7dr4CH50SXDo2dXVoZfHi4/Un5qKjK1gazpvOBqYid6srmtqawojQhurwvPPEbKBPoPwg==", 
        "community"=>{
          "join_with_invite_only"=>"0", 
          "users_can_invite_new_users"=>"1", 
          "private"=>"0", 
          "require_verification_to_post_listings"=>"0", 
          "show_category_in_listing_list"=>"0", 
          "show_listing_publishing_date"=>"0", 
          "listing_comments_in_use"=>"1", 
          "automatic_newsletters"=>"1", 
          "default_min_days_between_community_updates"=>"7", 
          "email_admins_about_new_members"=>"0"
        }, 
        "button"=>"", 
        "controller"=>"admin/communities", 
        "action"=>"update_settings", 
        "locale"=>"en"
      }
    }
  ]
end