require "spec_helper"

module Deb
  describe Account do
    describe :create do
      it "should create an account" do
        Account.create(name: "name", short_name: "short", kind: "asset", contra: false).should_not be_new_record
      end
    end

    describe :positions do
      before(:each) do
        @account = Account.new
      end

      it "should allow proper position" do
        @account.kind = "asset"
        @account.can_be_in?("debit").should be_true
      end

      it "should not allow wrong position" do
        @account.kind = "revenue"
        @account.can_be_in?("debit").should be_false
      end

      it "should allow proper contra position" do
        @account.contra = true
        @account.kind = "revenue"
        @account.can_be_in?("debit").should be_true
      end
    end

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

      it "should create a new account" do
        Account.should_receive(:where).with(short_name: "foobar").and_return(["mock"])
        Account["foobar"].should == "mock"
      end
    end
  end
end
