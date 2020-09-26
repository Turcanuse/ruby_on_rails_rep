#autor: SergheiScepanovschi
#ver 3.8
require 'date'
require 'watir'
require 'nokogiri'
require 'webdrivers'
require 'faker'
require 'rubygems'
require 'json'
require 'jsonapi-serializers'

class Transaction
  attr_accessor :name, :date, :description, :amount # открываем доступ r/w
  def initialize(v_name, v_date, v_description, v_amount)
    @name        = v_name,        #название
    @date        = v_date         #Дата
    @description = v_description  #описание
    @amount      = v_amount       #сумма
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

class Card
  attr_accessor :carrierName
  def initialize(v_carrierName)
    @carrierName        = v_carrierName       #имя владельца
  end
  def to_h
    {
        carrierName: carrierName
    }
  end
end

class Accaunt
  attr_accessor :name_accaunt, :currency, :availableBalance, :classification, :array_card,:array_transaction
  def initialize(v_nameAccaunt, v_currency, v_availableBalance, v_classification)
    @name_accaunt       = v_nameAccaunt      #имя
    @currency          = v_currency         #валюта
    @availableBalance  = v_availableBalance #баланс
    @classification    = v_classification   #природа
    @array_card        = Array.new         #карты
    @array_transaction = Array.new         #транзакции
  end
  def to_h
    {
        name_accaunt: name_accaunt,
        currency: currency,
        availableBalance: availableBalance,
        classification: classification,
        array_card: array_card.map(&:to_h),
        array_transaction: array_transaction.map(&:to_h)
    }
  end
  # Добавляем карту
  def addCard(v_carrierName)
    @array_card << Card.new(v_carrierName)        #push карты
  end
  #Добавить транзакцию
  def add_transaction(v_name, v_date, v_description, v_amount)
    array_transaction << Transaction.new(v_name, v_date, v_description, v_amount)        #push карты
  end
end


# добавляем новые элементы массива из JSON hash
array_accaunts = Array.new()
browser = Watir::Browser.new :firefox
def scroll_to_bottom(_browser)
  #скролим вниз сайта чтобы можно было бы подцепить весь список транзакций
  while _browser.text.include?("No more activity")==false do
    _browser.scroll.to :bottom
  end
end

#заходим на сайт
browser.goto "https://demo.bendigobank.com.au/banking/sign_in"

#кликаем на кнопку входа
browser.button(:name => "customer_type").click
#копируем необходимые данные
strct = browser.script(:id => "data").innertext

#Находим данные
pos1 = strct.rindex(/__DATA__/)
pos2 = strct.rindex(/__BOOTSTRAP_I18N__/)
pos1 =pos1+10
pos2 =pos2-69
# Копируем подстроку с данными
strct = strct.slice(pos1,pos2)
#здесь при парсинг JSON
my_hash = JSON.parse(strct)
i=0
 for item in my_hash["accounts"] do
    array_accaunts << Accaunt.new(item["name"], item["currentBalance"]["currency"], item["currentBalance"]["value"],item["classification"])
    for card in item["cards"] do
      array_accaunts[i].addCard(card["carrierName"])
    end
    i=i+1
 end

#TWO_MONTH                  = 60
#current_date               = Time.new.strftime('%Y-%m-%d')
#edge_date                  = Date.strptime(current_date) - TWO_MONTH
header_transaction_span    = '//span[@data-semantic="payment-amount"]'
properties_transaction_div = '//div[@class="uilist__item"]'
#transaction_li             = '//li[contains(@class, "grouped-list__group") and contains(@data-semantic, "activity-group")]'
#list_transaction_li        = './/li[@data-semantic="activity-item"]'
description_transaction_tag    = '//span[@class="uilist__item__detail"]'
i = 0
browser.elements(:xpath, '//li[@data-semantic="account-item"]').map do |build|
  if i < 4 then
    build.click
    sleep 10
    i+=1
  else
    break
  end
  # begin
  # transaction_date = Date.strptime(list_transaction.values.last)

  #скролим вниз
  #scroll_to_bottom(browser)
  j = 0
  browser.elements(:xpath, '//a[@class="_1pyzXOL8PW panel--hover"]').map do |transaction|
    if j < 10 then
      #кликаем по очерёдной транзакции
      transaction.click
      sleep 1
      j += 1
    else
      break
    end
    #собираем данные с транзакции
    header_transaction = browser.element(:xpath, header_transaction_span).text

    properties_transaction = browser.element(:xpath,properties_transaction_div)

    name_transaction        = properties_transaction.elements(:xpath,'//span[@class="uilist__item__label"]')[0].text
    date_transaction        = properties_transaction.elements(:xpath,'//span[@class="uilist__item__detail"]')[0].text
    description_transaction = properties_transaction.elements(:xpath,description_transaction_tag)[2].text
    amount_transaction = header_transaction.delete('Credit of ')
    array_accaunts[i-1].add_transaction(name_transaction, date_transaction, description_transaction, amount_transaction)

    browser.back
    #скролим вниз
    #scroll_to_bottom(browser)
  end

end
#while transaction_date < edge_date do

puts "------------------------------------------------------------------------------------"
js =array_accaunts.map(&:to_h).to_json

puts js
puts "------------------------------------------------------------------------------------"

