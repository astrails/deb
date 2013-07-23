module Deb
  class Account < ActiveRecord::Base
    belongs_to :accountable, polymorphic: true
    has_many :items
    has_many :transactions, through: :items

    validates :kind, inclusion: {in: %w(asset liability equity revenue expense)}

    attr_accessible :name, :kind, :short_name, :contra

    def self.[](some_shot_name)
      where(short_name: some_shot_name).first
    end
  end
end
