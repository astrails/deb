module Deb
  class Transaction < ActiveRecord::Base
    belongs_to :transactionable, polymorphic: true
    has_many :items
    has_many :accounts, through: :items
    has_many :debit_items, class_name: "Deb::Item", conditions: {kind: "debit"}
    has_many :debit_accounts, through: :debit_items, source: :account
    has_many :credit_items, class_name: "Deb::Item", conditions: {kind: "credit"}
    has_many :credit_accounts, through: :credit_items, source: :account

    validate :debit_items_presence
    validate :credit_items_presence
    validate :proper_amounts

    attr_accessible :transactionable, :description, :kind

    def self.start(&block)
      Docile.dsl_eval(Deb::Builder.new, &block).build
    end

    def self.start!(&block)
      transaction do
        start(&block).save!
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
