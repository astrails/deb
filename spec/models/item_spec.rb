require "spec_helper"

module Deb
  describe Item do
    before(:each) do
      @item = Item.new
    end

    describe :validations do
      [:kind, :account_id, :amount].each do |k|
        it "should validate #{k}" do
          @item.should_not be_valid
          @item.errors[k].should_not be_blank
        end
      end

      it "should validate junky kind" do
        @item.kind = "somejunk"
        @item.should_not be_valid
        @item.errors[:kind].should_not be_blank
      end

      ["debit", "credit"].each do |k|
        it "should pass #{k} as a kind" do
          @item.kind = k
          @item.valid?
          @item.errors[:kind].should be_blank
        end
      end
    end
  end
end

