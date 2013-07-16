require "spec_helper"

module Deb
  describe Item do
    before(:each) do
      @item = Item.new
    end

    describe :validations do
      [:kind, :account_id, :transaction_id, :amount].each do |k|
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

        describe :account_kind do
          before(:each) do
            @item.kind = "debit"
            @item.account_id = 1
            @item.transaction_id = 2
            @amock = mock("account")
            @item.stub!(:account).and_return(@amock)
          end

          it "should validate account_kind" do
            @amock.stub!(:can_be_in?).and_return(false)
            @item.valid?
            @item.errors[:account_id].should_not be_blank
          end

          it "should pass account_kind" do
            @amock.stub!(:can_be_in?).and_return(true)
            @item.valid?
            @item.errors[:account_id].should be_blank
          end
        end

      end
    end
  end
end

