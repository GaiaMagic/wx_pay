
class ServiceTest < MiniTest::Test

  # TODO why put the params of refun in setup method
  def setup
    @apiclient_cert = Minitest::Mock.new
    @apiclient_cert.expect(:certificate, 'certificate')
    @apiclient_cert.expect(:key, 'key')
  end

  def test_invoke_refund
    response_body = <<-EOF
     <xml>
       <return_code><![CDATA[SUCCESS]]></return_code>
       <return_msg><![CDATA[OK]]></return_msg>
       <appid><![CDATA[wx2421b1c4370ec43b]]></appid>
       <mch_id><![CDATA[10000100]]></mch_id>
       <nonce_str><![CDATA[NfsMFbUFpdbEhPXP]]></nonce_str>
       <sign><![CDATA[B7274EB9F8925EB93100DD2085FA56C0]]></sign>
       <result_code><![CDATA[SUCCESS]]></result_code>
       <transaction_id><![CDATA[1008450740201411110005820873]]></transaction_id>
       <out_trade_no><![CDATA[1415757673]]></out_trade_no>
       <out_refund_no><![CDATA[1415701182]]></out_refund_no>
       <refund_id><![CDATA[2008450740201411110000174436]]></refund_id>
       <refund_channel><![CDATA[]]></refund_channel>
       <refund_fee>1</refund_fee>
       <coupon_refund_fee>0</coupon_refund_fee>
     </xml>
    EOF

    FakeWeb.register_uri(
      :post,
      %r|https://api\.mch\.weixin\.qq\.com*|,
      body: response_body
    )

    WxPay.stub :apiclient_cert, @apiclient_cert do
      r = WxPay::Service.invoke_refund(
        transaction_id: '1217752501201407033233368018',
        op_user_id: '10000100',
        out_refund_no: '1415701182',
        out_trade_no: '1415757673',
        refund_fee: 1,
        total_fee: 1
      )

      assert_equal r.success?, true
    end
  end

  def test_invoke_merchant_pay
    response_body = <<-EOF
      <xml>
        <return_code><![CDATA[SUCCESS]]></return_code>
        <return_msg><![CDATA[]]></return_msg>
        <mch_appid><![CDATA[wxec38b8ff840bd989]]></mch_appid>
        <mchid><![CDATA[10013274]]></mchid>
        <device_info><![CDATA[]]></device_info>
        <nonce_str><![CDATA[lxuDzMnRjpcXzxLx0q]]></nonce_str>
        <result_code><![CDATA[SUCCESS]]></result_code>
        <partner_trade_no><![CDATA[10013574201505191526582441]]></partner_trade_no>
        <payment_no><![CDATA[1000018301201505190181489473]]></payment_no>
        <payment_time><![CDATA[2015-05-19 15:26:59]]></payment_time>
      </xml>
    EOF

    FakeWeb.register_uri(
      :post,
      %r|https://api\.mch\.weixin\.qq\.com*|,
      body: response_body
    )

    WxPay.stub :apiclient_cert, @apiclient_cert do
      r = WxPay::Service.invoke_merchant_pay(
        partner_trade_no: 'partner_trade_no',
        openid: 'openid',
        amount: 100,
        desc: 'desc',
        spbill_create_ip: '127.0.0.1'
      )
      assert_equal r.success?, true
    end
  end

  def test_accept_multiple_app_id_when_invoke
    params = {
      body: '测试商品',
      out_trade_no: 'test003',
      total_fee: 1,
      spbill_create_ip: '127.0.0.1',
      notify_url: 'http://making.dev/notify',
      trade_type: 'JSAPI',
      openid: 'OPENID',
      app_id: 'app_id',
      mch_id: 'mch_id',
      key: 'key'
    }
    xml_str = '<xml><body>测试商品</body><out_trade_no>test003</out_trade_no><total_fee>1</total_fee><spbill_create_ip>127.0.0.1</spbill_create_ip><notify_url>http://making.dev/notify</notify_url><trade_type>JSAPI</trade_type><openid>OPENID</openid><app_id>app_id</app_id><mch_id>mch_id</mch_id><sign>172A2D487A37D13FDE32B874BA823DD6</sign></xml>'
    assert_equal xml_str, WxPay::Service.send(:make_payload, params)
  end
end
