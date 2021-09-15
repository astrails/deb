module Deb
  class Entry < ActiveRecord::Base
    belongs_to :transactionable, polymorphic: true, optional: true
    has_many :items, foreign_key: :transaction_id
    has_many :accounts, through: :items
    has_many :debit_items, -> { where(kind: "debit") }, class_name: "Deb::Item", foreign_key: :transaction_id
    has_many :debit_accounts, through: :debit_items, source: :account
    has_many :credit_items, -> { where(kind: "credit") }, class_name: "Deb::Item", foreign_key: :transaction_id
    has_many :credit_accounts, through: :credit_items, source: :account
    belongs_to :rollback_transaction, class_name: "Deb::Entry", optional: true

    validate :debit_items_presence
    validate :credit_items_presence
    validate :proper_amounts

    after_create :lock_and_update_balances

    scope :not_rolled_back, -> { where("rollback_transaction_id is null") }

    self.table_name = "deb_transactions"

    #attr_accessible :transactionable, :description, :kind

    def rolled_back?
      rollback_transaction.present?
    end

    def self.start(&block)
      Docile.dsl_eval(Deb::Builder.new, &block).build
    end

    def lock_and_update_balances
      items.sort_by(&:account_id).each do |item|
        item.lock!
        item.account.lock!
        item.update_balances!
      end
    end

    def rollback!(ref = nil)
      tran = self
      res = self.class.start! do
        tran.debit_items.each { |di| credit(di.account, di.amount) }
        tran.credit_items.each { |ci| debit(ci.account, ci.amount) }
        reference(ref || tran)
        kind(tran.kind)
        description("Rollback of #{tran.description}")
      end
      self.rollback_transaction_id = res.id
      save!
      res
    end

    def self.start!(&block)
      transaction do
        start(&block).tap do |t|
          t.save!
        end
      end
    end

    def debit_items_presence
      errors.add(:base, "no debit items") if debit_items.blank?
    end

    def credit_items_presence
      errors.add(:base, "no credit items") if credit_items.blank?
    end

    def proper_amounts
      errors.add(:base, "wrong credit total is not equal debit total") unless credit_items.collect(&:amount).reduce(:+) == debit_items.collect(&:amount).reduce(:+)
    end

  end
end
