class InboxSerializer < ActiveModel::Serializer
  include TransactionHelper
  include IconHelper

  def attributes
    data = super
    data[:conversation_id] = object[:conversation_id]
    data[:type] = object[:type].to_s
    data[:other] = object[:other]
    data[:current] =  object[:current]
    data[:last_activity_ago] = object[:last_activity_ago]
    data[:title] = object[:title].present? ? object[:title] : "Message content not available"
    data[:path] = object[:path]
    data[:should_notify] = object[:should_notify]
    data[:listing_id] = object[:listing_url].present? ? object[:listing_id] : nil
    data[:listing_title] = object[:listing_url].present? && object[:listing_deleted] == false ? object[:listing_title] : nil
    data[:listing_url] = object[:listing_url].present? && object[:listing_deleted] == false ? object[:listing_url] : nil
    data[:sub_heading] = object[:listing_url].present? ? "About listing" : "Direct message"
    data[:status] = status
    data[:icon] = icon
    return data
  end

  def status
    if Community.last.payments_in_use?
      status = object[:last_transition_to_state]
      if status.present? && status != "free"
        status_meta = object[:transitions].last[:metadata]
        is_author = !object[:current_is_starter]
        waiting_feedback = object[:waiting_feedback]
        other_name = object[:other][:display_name]
        icon, status_description = conversation_icon_and_status(status, is_author, other_name, waiting_feedback, status_meta)      
        return status_description
      end
    end
  end

  def icon
    current_state = object[:last_transition_to_state]
    case current_state
    when "confirmed"
      if object[:waiting_feedback]
        {icon: 'exclamation-triangle', color: "#d0cb46"}
      else
        {icon: 'check', color: "#597d24"}
      end
    when "rejected"
      {icon: "times", color: "#a92b20"}
    when "canceled"
      {icon: "times", color: "#a92b20"}
    when "accepted"
      if object[:current_is_starter]
        {icon: 'exclamation-triangle', color: "#d0cb46"}
      else
        {icon: 'clock', color: "#989898"}
      end
    when "paid"
      if object[:current_is_starter]
        {icon: 'exclamation-triangle', color: "#d0cb46"}
      else
        {icon: 'clock', color: "#989898"}
      end      
    when "preauthorized"
      if object[:current_is_starter]
        {icon: 'clock', color: "#989898"}
      else
        {icon: 'exclamation-triangle', color: "#d0cb46"}
      end       
    when "pending_ext"
      "ss-alert"
    when "accept_preauthorized"
      "ss-check"
    when "reject_preauthorized"
      {icon: "times", color: "#a92b20"}
    when "errored"
      "ss-delete"
    end    
  end
end
