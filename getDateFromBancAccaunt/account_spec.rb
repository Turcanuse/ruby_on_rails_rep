# frozen_string_literal: true

# Information
# autor: Serghei Scepanovschi
# account_spe.rb ver 1.0
#
require_relative 'example_bank'
require 'rspec'
str = IO.read("temp.json")
my_hash = JSON.parse(str)
describe 'accounts' do
  it 'should receive 5 for accounts' do
    ExampleBank.connect
    ExampleBank.fetch_accounts
    ExampleBank.fetch_transactions
    expect(ExampleBank.accounts.count).to eq(5)
  end

  it 'should match data account and transaction' do
    expect(ExampleBank.accounts[0].to_h).to eq(my_hash[0])
  end
end




