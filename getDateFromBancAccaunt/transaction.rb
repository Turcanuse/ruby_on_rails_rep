# frozen_string_literal: true

# Information
# autor: Serghei Scepanovschi
# transaction.rb ver 1.0
#

# class to store Transaction data
class Transaction
  attr_accessor :date, :description, :amount, :currency, :account_name # we opened access for r/w

  def initialize(v_date, v_description, v_amount, v_currency, v_account_name)
    @date            = v_date         # date of transaction
    @description     = v_description  # description of transaction
    @amount          = v_amount       # amount of transaction
    @currency        = v_currency     # currency of transaction
    @account_name    = v_account_name # account wich make transaction
  end

  def to_h
    {
       date:         date,
       description:  description,
       amount:       amount,
       currency:     currency,
       account_name: account_name
    }
  end
end

