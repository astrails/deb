module Deb
  class Account < ActiveRecord::Base
    belongs_to :reference, polymorphic: true
    has_many :items
    has_many :transactions, through: :items

    validates :kind, inclusion: {in: %w(asset liability equity revenue expense)}

    def self.[](some_shot_name)
      where(short_name: some_shot_name).first
    end

    ACCOUNTS_POSITIONS = {
      "debit" => ["asset", "expense"],
      "credit" => ["liability", "equity", "revenue"]
    }

    def can_be_in?(position)
      ACCOUNTS_POSITIONS[contra? ? self.class.swap_position(position) : position].member?(kind)
    end

    def self.swap_position(value)
      "debit" == value ? "credit" : "debit"
    end
  end
end
