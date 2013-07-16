module Deb
  class Item < ActiveRecord::Base
    belongs_to :account
    belongs_to :transaction
    validates :kind, exclusion: {in: %w(debit credit)}
  end
end
