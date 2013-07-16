require "spec_helper"

module Deb
  describe Transaction do
    before(:each) do
      @transaction = Transaction.new
    end

    ["debit", "credit"].each do |k|
      it "should validate #{k} items" do
        @transaction.should_not be_valid
        @transaction.errors[:base].member?("no #{k} items").should be_true
      end
    end

    it "should validate amounts" do
      @transaction.debit_items.build(amount: 10)
      @transaction.credit_items.build(amount: 1)
      @transaction.should_not be_valid
      @transaction.errors[:base].member?("wrong credit total is not equal debit total").should be_true
    end
  end
end

