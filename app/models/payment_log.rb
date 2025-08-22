class PaymentLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :correlation_id, type: String
  field :amount, type: Float
  field :processed_via, type: String # default or fallback
  field :request_at, type: Time

  index({ correlation_id: 1 }, { unique: true })
  index({ created_at: 1 })
  index({ processed_via: 1 })
end
