module Deb
  class Item < ActiveRecord::Base
    belongs_to :account
    belongs_to :entry, foreign_key: :transaction_id, optional: true
    validates :kind, inclusion: {in: %w(debit credit)}
    validates :account_id, presence: true
    validate :positive_amount

    #attr_accessible :account, :amount

    def positive_amount
      errors.add(:amount, "should be positive") unless amount > 0
    end

    def update_balances!
      self.balance_before = account.current_balance
      self.balance_after = account.current_balance + op_sign * amount
      save!
      account.current_balance = balance_after
      account.save!
    end

    def op_sign
      "debit" == kind ? -1 : 1
    end
  end
end
