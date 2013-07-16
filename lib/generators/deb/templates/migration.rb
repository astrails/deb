class CreateDebTables < ActiveRecord::Migration
  def self.up
    create_table :deb_accounts do |t|
      t.string :name
      t.string :kind
      t.string :short_name, limit: 16
      t.references :reference, polymorphic: true
      t.boolean :contra
      t.decimal :current_balance, :precision => 20, :scale => 2
      t.timestamps
    end
    add_index :deb_accounts, :short_name
    add_index :deb_accounts, [:reference_type, :reference_id, :kind], name: "deb_accounts_default"

    create_table :deb_transactions do |t|
      t.string :description
      t.references :reference, polymorphic: true
      t.timestamps
    end
    add_index :deb_transactions, [:reference_type, :reference_id], name: "deb_transactions_default"

    create_table :deb_items do |t|
      t.string :kind
      t.integer :account_id
      t.integer :transaction_id
      t.decimal :amount, :precision => 20, :scale => 2
      t.decimal :balance_before, :precision => 20, :scale => 2
      t.decimal :balance_after, :precision => 20, :scale => 2
    end 
    add_index :deb_items, :account_id
    add_index :deb_items, [:transaction_id, :kind]
  end

  def self.down
    drop_table :deb_accounts
    drop_table :deb_transactions
    drop_table :deb_items
  end
end

