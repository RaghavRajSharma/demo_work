class Api::V1::InboxesController < Api::V1::BaseController
  swagger_controller :inboxes, 'inboxes'

  swagger_api :show do
    summary "Fetches all  conversations of a person"
    notes "This lists all conversations of a person"
    param :path, :id, :string, :required, "Username of a person to which conversations will be fetched."
    param :query, :page, :integer, :optional, "Page number"
    param :query, :per_page, :integer, :optional, "Per page"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end  

  def show
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      params[:page] ||= 1
      pagination_opts = PaginationViewUtils.parse_pagination_opts(params)
      inbox_rows = MarketplaceService::Inbox::Query.inbox_data(person.id, current_community.id,pagination_opts[:limit], pagination_opts[:offset])
      count = MarketplaceService::Inbox::Query.inbox_data_count(person.id, current_community.id)
      inbox_rows = inbox_rows.map { |inbox_row|
        extended_inbox = inbox_row.merge(
          path: path_to_conversation_or_transaction(inbox_row),
          other: person_entity_with_url(inbox_row[:other]),
          last_activity_ago: ApplicationController.helpers.time_ago(inbox_row[:last_activity_at]),
          title: inbox_title(inbox_row, inbox_payment(inbox_row))
        )
        if inbox_row[:type] == :transaction
          extended_inbox.merge(
            listing_url: listing_path(id: inbox_row[:listing_id])
          )
        else
          extended_inbox
        end
      }
      paginated_inbox_rows = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], count) do |pager|
        pager.replace(inbox_rows)
      end
      render json: paginated_inbox_rows, each_serializer: InboxSerializer, status: 200
    else
      render json: {error: "Perosn not found."}, error: 404
    end  
  end

  private 
    def inbox_title(inbox_item, payment_sum)
      title = if MarketplaceService::Inbox::Entity.last_activity_type(inbox_item) == :message
        inbox_item[:last_message_content]
      else
        action_messages = TransactionViewUtils.create_messages_from_actions(
          inbox_item[:transitions],
          inbox_item[:other],
          inbox_item[:starter],
          payment_sum
        )

        action_messages.last[:content]
      end
    end

    def path_to_conversation_or_transaction(inbox_item)
      if inbox_item[:type] == :transaction
        api_v1_transaction_path(id: inbox_item[:transaction_id])
      else
        api_v1_conversation_path(id: inbox_item[:conversation_id])
      end
    end    

    def inbox_payment(inbox_item)
      Maybe(inbox_item)[:payment_total].or_else(nil)
    end    
     

    def person_entity_with_url(person_entity)
      person_entity.merge({
                            url: person_path(username: person_entity[:username]),
                            display_name: PersonViewUtils.person_entity_display_name(person_entity, current_community.name_display_type)
                          })
    end      
end
