class PaymentsSummaryController < ActionController::API
  
  def show
    from = parse_time(require(:from))
    to = parse_time(require(:to))

    scope = PaymentLog.all
    scope = scope.where(:created_at.gte => from) if from
    scope = scope.where(:created_at.lte => to) if to

    default_count = scope.where(processed_via: 'default').count
    default_sum = scope.where(processed_via: 'default').sum(:amount) || 0
    fallback_count = scope.where(processed_via: 'fallback').count
    fallback_sum = scope.where(processed_via: 'fallback').sum(:amount) || 0

    render json: {
      default: { totalRequests: default_count, totalAmount: default_sum.to_f },
      fallback: { totalRequests: fallback_count, totalAmount: fallback_sum.to_f }
    }, status: 200
  rescue ActionController::ParameterMissing => e
    render json: { error: "bad_request", details: e.message }, status: 400
  rescue => e
    render json: { error: "internal_error", details: e.message }, status: 500
  end


  private

  def parse_time(str)
    return nil if str.blank?
    Time.iso8601(str)
  rescue ArgumentError
    nil  
  end
end
