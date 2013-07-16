module Deb
  class Item < ActiveRecord::Base
    belongs_to :account
    belongs_to :transaction
    validates :kind, inclusion: {in: %w(debit credit)}
    validates :account_id, presence: true
    validate :account_kind
    validate :positive_amount

    attr_accessible :account, :amount

    def account_kind
      errors.add(:account_id, "account cannot be in #{kind}") if !account || !account.can_be_in?(kind)
    end

    def positive_amount
      errors.add(:amount, "should be positive") unless amount > 0
    end
  end
end
