module Deb
  class Item < ActiveRecord::Base
    belongs_to :account
    belongs_to :transaction
    validates :kind, inclusion: {in: %w(debit credit)}
    validates :account_id, :transaction_id, presence: true
    validate :account_kind
    validate :non_zero_amount

    def account_kind
      errors.add(:account_id, "account cannot be in #{kind}") if !account || !account.can_be_in?(kind)
    end

    def non_zero_amount
      errors.add(:amount, "cannot be zero") if amount.zero?
    end
  end
end
