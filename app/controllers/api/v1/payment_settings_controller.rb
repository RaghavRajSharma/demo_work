class Api::V1::PaymentSettingsController < Api::V1::BaseController
  swagger_controller :payment_settings, 'Payment Settings'

  swagger_api :get_keys do
    summary "Get Stripe publish key and secret key"
    notes "This end point is used to get stripe publish key and secret keys"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def get_keys
    payment_gateway =PaymentSettings.find_by(payment_gateway: "stripe")
    if payment_gateway.present?
      render json: {publish_key: payment_gateway.api_publishable_key , secret_key: TransactionService::Store::PaymentSettings.decrypt_value(payment_gateway.api_private_key)}, status: 200
    else
      render json: {error: "Payment Gateway not found!"} , status: 404
    end
  end
end
