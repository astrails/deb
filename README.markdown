## Double Entry Bookkeeping for Rails

Inspired by (plutus)[https://github.com/mbulat/plutus].

Installation

      gem "deb"

      rails g deb
      rake db:migrate


Example

      @asset = Account.create(kind: "asset")
      @revenue = Account.create(kind: "revenue")
      @liability = Account.create(kind: "liability")

      Transaction.start! do
        debit @asset, 12
        credit @revenue, 5
        credit @liability, 7
        description "foobar"
        reference @mysome_record
      end

TODO: more documentation: balances


Copyright (c) 2013 Boris Nadion

