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

  describe :builder do
    before(:each) do
      @asset = Account.create(kind: "asset")
      @revenue = Account.create(kind: "revenue")
      @liability = Account.create(kind: "liability")
    end

    describe :transactional do
      it "should save the record" do
        lambda {
          Transaction.start! do
            debit @asset, 12
            credit @revenue, 5
            credit @liability, 7
            description "foobar"
            kind "foobar"
          end
        }.should change(Transaction, :count).by(1)
      end

      it "should fail child validations and raise" do
        @wrong = Account.create(kind: "equity")
        lambda {
          Transaction.start! do
            debit @wrong, 12
            credit @revenue, 5
            credit @liability, 1
            description "foobar"
          end
        }.should raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe :few_accounts do
      before(:each) do
        @transaction = Transaction.start do
          debit @asset, 12
          credit @liability, 7
          credit @liability, 5
          description "foobar"
        end

        it "should be valid" do
          @transaction.should be_valid
        end

        it "should sum amounts" do
          @transaction.credit_items.collect(&:amount).should == [12]
        end
      end

    end

    describe :simple_build do
      before(:each) do
        @transaction = Transaction.start do
          debit @asset, 12
          credit @revenue, 5
          credit @liability, 7
          description "foobar"
        end
      end

      it "should be valid" do
        @transaction.should be_valid
      end

      it "should set description" do
        @transaction.description.should == "foobar"
      end

      it "should set debit" do
        @transaction.debit_items.size.should == 1
        @transaction.debit_items.first.account.should == @asset
        @transaction.debit_items.first.amount.should == 12
      end

      it "should set credit" do
        @transaction.credit_items.size.should == 2
        @transaction.credit_items.collect(&:account).should == [@revenue, @liability]
        @transaction.credit_items.collect(&:amount).should == [5, 7]
      end

      it "should save all records" do
        lambda {
          @transaction.save!
        }.should change(Item, :count).by(3)
      end

      it "should update item balances" do
        @transaction.save!
        @transaction.debit_items.first.balance_before.should == 0
        @transaction.debit_items.first.balance_after.should == -12
        @transaction.credit_items.first.balance_before.should == 0
        @transaction.credit_items.first.balance_after.should == 5
        @transaction.credit_items.last.balance_before.should == 0
        @transaction.credit_items.last.balance_after.should == 7
      end

      it "should update account balances" do
        @transaction.save!
        @asset.reload.current_balance.should == -12
        @revenue.reload.current_balance.should == 5
        @liability.reload.current_balance.should == 7
      end
    end
  end
end

