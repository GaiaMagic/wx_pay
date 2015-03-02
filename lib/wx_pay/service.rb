require 'cgi'
require 'open-uri'

module WxPay
  module Service
    GATEWAY_URL = 'https://api.mch.weixin.qq.com/pay'

    INVOKE_UNIFIEDORDER_REQUIRED_FIELDS = %i(body out_trade_no total_fee spbill_create_ip notify_url trade_type)
    def self.invoke_unifiedorder(params)
      params = {
        appid: WxPay.appid,
        mch_id: WxPay.mch_id,
        nonce_str: SecureRandom.uuid.tr('-', ''),
      }.merge(params)

      check_required_options(params, INVOKE_UNIFIEDORDER_REQUIRED_FIELDS)

      r = invoke_remote("#{GATEWAY_URL}/unifiedorder", make_payload(params))

      yield r if block_given?

      r
    end

    CLOSE_ORDER_REQUIRED_FIELDS = %i(out_trade_no)
    def self.close_order(params)
      params = {
        appid: WxPay.appid,
        mch_id: WxPay.mch_id,
        nonce_str: SecureRandom.uuid.tr('-', ''),
      }.merge(params)

      check_required_options(params, CLOSE_ORDER_REQUIRED_FIELDS)

      r = invoke_remote("#{GATEWAY_URL}/closeorder", make_payload(params))

      yield r if block_given?

      r
    end

    private

    def self.check_required_options(options, names)
      return if !WxPay.debug_mode?

      names.each do |name|
        warn("WxPay Warn: missing required option: #{name}") unless options.has_key?(name)
      end
    end

    def self.make_payload(params)
      "<xml>#{params.map { |k, v| "<#{k}>#{v}</#{k}>" }.join}<sign>#{WxPay::Sign.generate(params)}</sign></xml>"
    end

    def self.invoke_remote(url, payload)
      r = RestClient::Request.execute(
        {
          method: :post,
          url: url,
          payload: payload,
          headers: { content_type: 'application/xml' }
        }.merge(WxPay.extra_rest_client_options)
      )

      r && WxPay::Result.new(Hash.from_xml(r))
    end
  end
end
