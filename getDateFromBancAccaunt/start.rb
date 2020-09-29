# frozen_string_literal: true

require 'date'
require 'json'
require 'nokogiri'
require 'watir'
require 'webdrivers'

TWO_MONTH = 5.freeze

class Transaction
  attr_accessor :name, :date, :description, :amount

  def initialize(v_name, v_date, v_description, v_amount)
    @name        = v_name
    @date        = v_date
    @description = v_description
    @amount      = v_amount
  end

  def to_h
    {
        name: name,
        date: date,
        description: description,
        amount: amount
    }
  end
end

class Accaunt
  attr_accessor :name_accaunt, :currency, :availableBalance,
                :classification, :array_card,:array_transaction

  def initialize(v_nameAccaunt, v_currency, v_availableBalance, v_classification)
    @name_accaunt      = v_nameAccaunt
    @currency          = v_currency
    @availableBalance  = v_availableBalance
    @classification    = v_classification
    @array_transaction = []
  end

  def to_h
    {
        name_accaunt: name_accaunt,
        currency: currency,
        availableBalance: availableBalance,
        classification: classification,
        array_transaction: array_transaction.map(&:to_h)
    }
  end

  def add_transaction(v_name, v_date, v_description, v_amount)
    array_transaction << Transaction.new(v_name, v_date, v_description, v_amount)
  end
end

def scroll_to_bottom(browser)
  while browser.text.include?('No more activity') == false
    browser.scroll.to :bottom
  end
end

array_accaunts = []
container_attributes = []
date_transaction = ''
description_transaction = ''
current_date = Time.now.strftime('%e %b %Y')
edge_date = Date.parse(current_date.to_str) - TWO_MONTH

browser = Watir::Browser.new :firefox
browser.goto 'https://demo.bendigobank.com.au/banking/sign_in'
browser.button(:name => 'customer_type').click
strct = browser.script(:id => 'data').innertext

pos1 = strct.rindex(/__DATA__/)
pos2 = strct.rindex(/__BOOTSTRAP_I18N__/)
pos1 += 10; pos2 -= 69

strct = strct.slice(pos1, pos2)
my_hash = JSON.parse(strct)
my_hash['accounts'].each_with_index do |item|
  array_accaunts << Accaunt.new(
      item['name'],
      item['currentBalance']['currency'],
      item['currentBalance']['value'],
      item['classification']
  )
end
scroll_to_bottom(browser)
browser.elements(xpath: '//li[@data-semantic="account-item"]').each_with_index do |build, index|
  index < 4 ? (sleep 5; build.click) : break
  puts index
  browser.elements(xpath: '//li[@data-semantic="activity-item"]').each do |transaction|
    transaction.wait_until_present.scroll.to #нужно подождать пока появится обьект иначе будет ошибка
    transaction.click
    sleep 2
    header_transaction = Nokogiri::HTML(browser.html).css('span[data-semantic="payment-amount"]')
    properties_transaction = Nokogiri::HTML(browser.html).css('nav[class="uilist"] > div[class="uilist__item"]')
    array2 = ['Paid on', 'Payment Date', 'Description']
    amount_transaction = header_transaction.children.last.text.delete('$')
    properties_transaction.each do |list_item|
      a = list_item.css('span[class="uilist__item__label"]').text
      b = list_item.css('span[class="uilist__item__label"] + span[class="uilist__item__detail"]')
      c = b ? b.text : 'None'
      array1 = [a, c]
      container_attributes.push(array1)
    end

    name_transaction = container_attributes.first[0]
    date = {}
    container_attributes.each do |item_atr|
      if item_atr.first.eql?(array2.first) || item_atr.first.eql?(array2[1])
        date[:date] = Date.parse(item_atr[1])
      elsif item_atr[0].eql?(array2[2])
        date[:any] = item_atr[1]
      end
    end

    next if date[:date] < edge_date

    array_accaunts[index - 1].add_transaction(
        name_transaction, date_transaction,
        description_transaction,
        amount_transaction
    )
    browser.back; sleep 3
  end
end

puts '-' * 42
js =array_accaunts.map(&:to_h).to_json

puts js
puts '-' * 42