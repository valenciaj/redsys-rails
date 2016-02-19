module Redsys
  class NotificationsController < ApplicationController
    skip_before_filter :verify_authenticity_token

    #
    # Tratamiento para la notificación online
    # - Ds_Response == "0000" => Transacción correcta
    #
    def notification
      json_params = JSON.parse(Base64.urlsafe_decode64(params[:Ds_MerchantParameters]))

      if Redsys::Tpv.response_signature(params[:Ds_MerchantParameters]) == params[:Ds_Signature]
        # Enter only if the signature from the gateway is correct
        #TODO: Put your stuff regarding the transaction here. For instance, having a model defined for the tpv transactions you could store all the transaction info
=begin
        # Should you have a model TpvTransaction with the proper fields you could use this code for storing the info
        # The record should/could be already created in the DB if it's related to orders or payments already generated
        tpv_tx = TpvTransaction.find(json_params["Ds_Order"])
        tpv_tx.transaction_date = Date.strptime(URI.unescape(json_params["Ds_Date"]),"%d/%m/%Y").strftime("%d/%m/%Y")
        tpv_tx.transaction_time = Time.parse(URI.unescape(json_params["Ds_Hour"])).strftime("%H:%M")
        tpv_tx.amount = json_params["Ds_Amount"].to_i # stored as cents
        tpv_tx.currency = json_params["Ds_Currency"].to_i
        tpv_tx.merchant_code = json_params["Ds_MerchantCode"]
        tpv_tx.terminal = json_params["Ds_Terminal"].to_i
        tpv_tx.response_code = json_params["Ds_Response"].present? ? json_params["Ds_Response"].to_i : nil
        tpv_tx.merchant_data = json_params["Ds_MerchantData"]
        tpv_tx.secure_payment = json_params["Ds_SecurePayment"]
        tpv_tx.transaction_type = json_params["Ds_TransactionType"]
        tpv_tx.card_country = json_params["Ds_Card_Country"].to_i unless json_params["Ds_Card_Country"].nil? || json_params["Ds_Card_Country"].blank?
        tpv_tx.authorisation_code = json_params["Ds_AuthorisationCode"] unless json_params["Ds_AuthorisationCode"].nil? || json_params["Ds_AuthorisationCode"].blank?
        tpv_tx.consumer_language = json_params["Ds_ConsumerLanguage"].to_i unless json_params["Ds_ConsumerLanguage"].nil? || json_params["Ds_ConsumerLanguage"].blank?
        tpv_tx.card_type = json_params["Ds_Card_Type"] unless json_params["Ds_Card_Type"].nil? || json_params["Ds_Card_Type"].blank?
        tpv_tx.save
=end
        if json_params["Ds_Response"].present? && (json_params["Ds_Response"].to_i >= 0 && json_params["Ds_Response"].to_i <= 99)
          # The transaction result is ok. Register the payment here
          status = :ok
        else
          # The transaction failed, handle the exception however you want
          status = :bad_request
        end
      end
      render nothing: true, layout: false, status: status
    end
  end
end