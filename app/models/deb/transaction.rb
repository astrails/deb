module Deb
  class Transaction < ActiveRecord::Base
    belongs_to :reference, polymorphic: true
    has_many :items
    has_many :accounts, through: :items
    has_many :debit_items, class_name: "Deb::Item", conditions: {kind: "debit"}
    has_many :debit_accounts, through: :debit_items
    has_many :credit_items, class_name: "Deb::Item", conditions: {kind: "credit"}
    has_many :credit_accounts, through: :credit_items

    def self.start(&block)
      Docile.dsl_eval(Deb::Builder.new, &block).build
    end

  end
end
