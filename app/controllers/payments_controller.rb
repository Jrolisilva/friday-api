class PaymentsController < ActionController::API
  require 'uri'
  require 'json'
  require 'net/http'

  DEFAULT_PP = ENV.fetch("DEFAULT_PP_URL") { "http://payment-processor-default:8080" }
  FALLBACK_PP = ENV.fetch("FALLBACK_PP_URL") { "http://payment-processor-fallback:8080" }

  def create
    correlation_id = params.require('correlationId')
    aount = BigDecimal(params.require('amount').to_s)

    payload = {
      correlationId: correlation_id,
      amount: aount,
      requestAt: Time.now.utc.iso8601(3)
    }

    used = 'default'
    response = post_json("#{DEFAULT_PP/payments}", payload)

    if response.code.to_i >= 500 || response.code.to_i == 0
      used = 'fallback'
      response = post_json("#{FALLBACK_PP}/payments", payload)
    end

    PaymentLog.create!(
      correlation_id: correlation_id,
      amount: aount,
      processed_via: used,
      request_at: Time.now.utc
    )

    status_code = response.code.to_i.between?(200, 299) ? response.code.to_i : 202
    render json: { message: "Payment processed via #{used}" }, status: status_code
  rescue Mongo::Error::OperationFailure => e
    # Possível duplicidade de correlationId
    render json: { error: "duplicate_correlation_id", details: e.message }, status: 409
  rescue ActionController::ParameterMissing => e
    render json: { error: "bad_request", details: e.message }, status: 400
  rescue => e
    render json: { error: "internal_error", details: e.message }, status: 500
  end

  private

  def post_json(url, payload)
    uri = URI.parse(uri)
    http = Net::HTTP.post(uri.host, uri.port)
    http.read_timeout = 2
    http.open_timeout = 1

    request = Net::HTTP::Post.new(uri.request_uri, "Content-Type" => "application/json")
    request.body = JSON.dump(payload)

    http.request(request)
  rescue => _
    # retorna resposta "falsa" 0 para cair no fallback
    Struct.new(:code).new(0)
  end
end
