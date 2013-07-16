module Deb
  class Transaction < ActiveRecord::Base
    belongs_to :reference, polymorphic: true
    has_many :items
    has_many :accounts, through: :items
    has_many :debit_items, class_name: "Deb::Item", conditions: {kind: "debit"}
    has_many :debit_accounts, through: :debit_items
    has_many :credit_items, class_name: "Deb::Item", conditions: {kind: "credit"}
    has_many :credit_accounts, through: :credit_items

    validate :proper_amounts

    attr_accessible :reference, :description

    def self.start(&block)
      Docile.dsl_eval(Deb::Builder.new, &block).build
    end

    def proper_amounts
      errors.add(:base, "no debit items") if debit_items.blank?
      errors.add(:base, "no credit items") if credit_items.blank?
      errors.add(:base, "wrong credit total is not equal debit total") unless credit_items.collect(&:amount).reduce(:+) == debit_items.collect(&:amount).reduce(:+)
    end

  end
end
