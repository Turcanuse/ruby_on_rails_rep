# frozen_string_literal: true

# Information
# autor: Serghei Scepanovschi
# start.rb ver 4.0
#

require 'date'
require 'json'
require 'nokogiri'
require 'watir'
require 'webdrivers'
require_relative 'account'



array_accounts = []
container_attributes = []
date_transaction = ''
description_transaction = ''
TWO_MONTH = 60
current_date = Time.now.strftime('%e %b %Y')
edge_date = Date.parse(current_date) - TWO_MONTH

browser = Watir::Browser.new :firefox
browser.goto 'https://demo.bendigobank.com.au/banking/sign_in'
browser.button(name: 'customer_type').click
strct = browser.script(id: 'data').innertext

pos1 = strct.rindex(/__DATA__/)
pos2 = strct.rindex(/__BOOTSTRAP_I18N__/)
pos1 += 10
pos2 -= 69

strct = strct.slice(pos1, pos2)
my_hash = JSON.parse(strct)
my_hash['accounts'].each do |item|
  array_accounts << Account.new(
    item['name'],
    item['currentBalance']['currency'],
    item['currentBalance']['value'],
    item['classification']
  )
end

account_css_selector = 'li[data-semantic="account-item"]'
transaction_css_selector = 'li[data-semantic="activity-item"]'
header_css_selector = 'span[data-semantic="payment-amount"]'
properties_css_selector = 'nav[class="uilist"] > div[class="uilist__item"]'
label__css_selector = 'span[class="uilist__item__label"]'
detail_css_selector = 'span[class="uilist__item__label"] + span[class="uilist__item__detail"]'
accounts_box = browser.elements(css: 'li[data-semantic="account-group"]')[0]
# scroll_to_bottom(browser)

label_list = ['Paid on', 'Payment Date', 'Description']
accounts_box.elements(css: account_css_selector).each_with_index do |build, index|
  currency_transaction = array_accounts[index].currency
  account_name = array_accounts[index].name
  build.wait_until_present.click
  sleep 5
  #scroll_to_bottom(browser)
  browser.elements(css: transaction_css_selector).each do |transaction|
    transaction.wait_until_present.scroll.to # we have to wait till object will be available
    transaction.click
    sleep 2
    header_transaction = Nokogiri::HTML(browser.html).css(header_css_selector)
    properties_transaction = Nokogiri::HTML(browser.html).css(properties_css_selector)
    amount_transaction = header_transaction.children.last.text.delete('$')
    container_attributes = []
    properties_transaction.each do |list_item|
      label_item = list_item.css(label__css_selector).text
      detail_item = list_item.css(detail_css_selector)
      detail_item = detail_item ? detail_item.text : 'None'
      array_atr = [label_item, detail_item]
      container_attributes << array_atr
    end

    name_transaction = container_attributes.first[0]
    date = {}
    container_attributes.each do |item_atr|
      if item_atr.first.eql?(label_list.first) || item_atr.first.eql?(label_list[1])
        date[:date] = Date.parse(item_atr[1])
      elsif item_atr[0].eql?(label_list[2])
        date[:any] = item_atr[1]
      end
    end
    date_transaction = date[:date]
    description_transaction = date[:any]
    browser.back
    sleep 3
    # break if date[:date] < edge_date
    array_accounts[index].add_transaction(
      date_transaction, description_transaction,
      amount_transaction, currency_transaction,
      account_name
    )
  end
end


