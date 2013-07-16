module Deb
  class Account < ActiveRecord::Base
    belongs_to :reference, polymorphic: true
    has_many :items
    has_many :transactions, through: :items

    validates :kind, inclusion: {in: %w(asset liability equity revenue expense)}

    def self.[](some_shot_name)
      where(short_name: some_shot_name).first
    end
  end
end
