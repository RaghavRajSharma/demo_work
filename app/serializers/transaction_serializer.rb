# == Schema Information
#
# Table name: transactions
#
#  id                                :integer          not null, primary key
#  starter_id                        :string(255)      not null
#  starter_uuid                      :binary(16)       not null
#  listing_id                        :integer          not null
#  listing_uuid                      :binary(16)       not null
#  conversation_id                   :integer
#  automatic_confirmation_after_days :integer          not null
#  community_id                      :integer          not null
#  community_uuid                    :binary(16)       not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  starter_skipped_feedback          :boolean          default(FALSE)
#  author_skipped_feedback           :boolean          default(FALSE)
#  last_transition_at                :datetime
#  current_state                     :string(255)
#  commission_from_seller            :integer
#  minimum_commission_cents          :integer          default(0)
#  minimum_commission_currency       :string(255)
#  payment_gateway                   :string(255)      default("none"), not null
#  listing_quantity                  :integer          default(1)
#  listing_author_id                 :string(255)      not null
#  listing_author_uuid               :binary(16)       not null
#  listing_title                     :string(255)
#  unit_type                         :string(32)
#  unit_price_cents                  :integer
#  unit_price_currency               :string(8)
#  unit_tr_key                       :string(64)
#  unit_selector_tr_key              :string(64)
#  payment_process                   :string(31)       default("none")
#  delivery_method                   :string(31)       default("none")
#  shipping_price_cents              :integer
#  availability                      :string(32)       default("none")
#  booking_uuid                      :binary(16)
#  deleted                           :boolean          default(FALSE)
#  shipping_tracking_number          :string(255)
#  tax_cents                         :integer
#
# Indexes
#
#  index_transactions_on_community_id        (community_id)
#  index_transactions_on_conversation_id     (conversation_id)
#  index_transactions_on_deleted             (deleted)
#  index_transactions_on_last_transition_at  (last_transition_at)
#  index_transactions_on_listing_author_id   (listing_author_id)
#  index_transactions_on_listing_id          (listing_id)
#  index_transactions_on_starter_id          (starter_id)
#  transactions_on_cid_and_deleted           (community_id,deleted)
#

class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :status, :listing_id, :commission_from_seller, :minimum_commission_cents, :minimum_commission_currency
  has_one :conversation, :serializer => ConversationSerializer
  has_one :shipping_address, :serializer => ShippingAddressSerializer

  def status
    object.status
  end
end
