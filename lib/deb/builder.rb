module Deb
  class Builder
    attr_reader :debits, :credits, :description, :reference

    def debit(account, amount)
      @debits ||= {}
      @debits[account] = amount
    end

    def credit(account, amount)
      @credits ||= {}
      @credits[account] = amount
    end

    def description(desc)
      @description = desc
    end

    def reference(ref)
      @reference = ref
    end

    def initialize
      @debits ||= {}
      @credits ||= {}
    end

    def build
      Deb::Transaction.new(description: @description, reference: @reference) do |t|
        t.reference = @reference
        credits.each do |account, amount|
          t.credit_items.build(account: account, amount: amount)
        end
        debits.each do |account, amount|
          t.debit_items.build(account: account, amount: amount)
        end
      end
    end

  end
end
