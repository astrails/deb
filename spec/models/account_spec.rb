require "spec_helper"

module Deb
  describe Account do
    describe :validations do
      before(:each) do
        @account = Account.new
      end

      it "should validate empty kind" do
        @account.should_not be_valid
        @account.errors[:kind].should_not be_blank
      end

      it "should validate junky kind" do
        @account.kind = "some junk"
        @account.should_not be_valid
        @account.errors[:kind].should_not be_blank
      end

      %w(asset liability equity revenue expense).each do |k|
        it "should allow #{k} account kind" do
          @account.kind = k
          @account.should be_valid
        end
      end

      it "should search by short name" do
        Account.should_receive(:where).with(short_name: "foobar").and_return(["mock"])
        Account["foobar"].should == "mock"
      end
    end
  end
end
