module Deb
  class Builder
    attr_reader :debits, :credits, :description, :reference

    def debit(account, amount)
      @debits ||= {}
      @debits[account] ||= 0
      @debits[account] += amount
    end

    def credit(account, amount)
      @credits ||= {}
      @credits[account] ||= 0
      @credits[account] += amount
    end

    def description(desc)
      @description = desc
    end

    def kind(kind)
      @kind = kind
    end

    def reference(ref)
      @reference = ref
    end

    def initialize
      @debits ||= {}
      @credits ||= {}
    end

    def build
      Deb::Transaction.new(description: @description, transactionable: @reference, kind: @kind) do |t|
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
