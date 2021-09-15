require "spec_helper"

module Deb
  describe Entry do
    before(:each) do
      @transaction = Entry.new
    end

    ["debit", "credit"].each do |k|
      it "should validate #{k} items" do
        @transaction.should_not be_valid
        @transaction.errors[:base].member?("no #{k} items").should be_truthy
      end
    end

    it "should validate amounts" do
      @transaction.debit_items.build(amount: 10)
      @transaction.credit_items.build(amount: 1)
      @transaction.should_not be_valid
      @transaction.errors[:base].member?("wrong credit total is not equal debit total").should be_truthy
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
          Entry.start! do
            debit @asset, 12
            credit @revenue, 5
            credit @liability, 7
            description "foobar"
            kind "foobar"
          end
        }.should change(Entry, :count).by(1)
      end

      it "should fail child validations and raise" do
        @wrong = Account.create(kind: "equity")
        lambda {
          Entry.start! do
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
        @transaction = Entry.start do
          debit @asset, 12
          credit @liability, 7
          credit @liability, 5
          description "foobar"
        end
      end

      it "should be valid" do
        @transaction.should be_valid
      end

      it "should sum credit amounts" do
        @transaction.credit_items.collect(&:amount).should == [12]
      end

      it "should sum debit amounts" do
        @transaction.debit_items.collect(&:amount).should == [12]
      end
    end

    describe :simple_build do
      before(:each) do
        @transaction = Entry.start do
          debit @asset, 12
          credit @revenue, 5
          credit @liability, 7
          description "foobar"
          kind "baz"
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
        @transaction.reload.debit_items.first.balance_before.should == 0
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

      it "should receive custom rollback references" do
        @transaction.save!
        transaction2 = Entry.start do
          debit @asset, 12
          credit @revenue, 5
          credit @liability, 7
          description "foobar"
          kind "baz"
        end
        transaction2.save!
        @rollback = @transaction.rollback!(transaction2)
        @rollback.transactionable.should == transaction2
      end

      describe :default_rollback do
        before(:each) do
          @transaction.save!
          @rollback = @transaction.rollback!
        end

        it "should keep the reference" do
          @rollback.transactionable.should == @transaction
        end

        it "should assign the rollback transaction" do
          @transaction.rollback_transaction.id.should == @rollback.id
        end

        it "should be okay" do
          @rollback.should_not be_new_record
        end

        it "should set description" do
          @rollback.description.should == "Rollback of foobar"
        end

        it "should preserve transaction kind" do
          @rollback.kind.should == @transaction.kind
        end

        it "should set debit accounts" do
          @rollback.debit_items.collect(&:account).should == [@revenue, @liability]
        end

        it "should set credit accounts" do
          @rollback.credit_items.collect(&:account).should == [@asset]
        end

        it "should revert balances" do
          [@asset, @revenue, @liability].each do |a|
            a.current_balance.should == 0
          end
        end
      end
    end
  end
end

