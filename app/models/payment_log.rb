class PaymentLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :correlation_id, type: String
  field :amount, type: BigDecimal
  field :processed_via, type: String # default or fallback
  field :request_at, type: Time

  index({ correlation_id: 1 }, { unique: true })
  index({ created_at: 1 })
  index({ processed_via: 1 })

  validates :correlation_id, presence: true, uniqueness: true
  validates :amount, presence: true
  validates :processed_via, inclusion: { in: %w[default fallback] }
end
