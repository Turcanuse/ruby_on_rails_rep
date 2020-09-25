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
  attr_accessor :date, :description, :amount # открываем доступ r/w
  def initialize(v_date, v_description, v_amount)
    @date        = v_date         #Дата
    @description = v_description  #описание
    @amount      = v_amount       #сумма
  end
  def to_h
    {
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

  def exec
    puts @nameAccaunt, @currency, @availableBalance, @classification
    puts "===================="
    for item in @array_card do
      puts  item.exec # не подсвечивает метод
    end
    puts "===================="
  end
end
# добавляем новые элементы массива из JSON hash
array_accaunts = Array.new()
browser = Watir::Browser.new :firefox


#заходим на сайт
browser.goto "https://demo.bendigobank.com.au/banking/sign_in"

#кликаем на кнопку входа
browser.button(:name => "customer_type").click
#копируем необходимые данные
strct = browser.script(:id => "data").innertext

#doc =Nokogiri::HTML(browser.html)

browser.elements(:xpath, '//li[@data-semantic="account-item"]').map do |build|
  build.click
  # Watir::Wait.until { ... }
  #скролим вниз сайта чтобы можно было бы подцепить весь список транзакций
  while browser.text.include?("No more activity")==false do
    browser.scroll.to :bottom
  end
  #кликаем поочерёдно по всем транзакциям
  browser.elements(:xpath, '//a[@class="_1pyzXOL8PW panel--hover"]').map do |transaction|
     transaction.click
     sleep 3
     #берём значения со страницы транзакции
     #собираем данные с транзакции
     #name_transaction = browser.h2(class: 'overflow-ellipsis panel__header__label__primary').text
     #puts name_transaction
     #amount_transaction = browser.span(class: 'overflow-ellipsis amount').text
     #puts amount_transaction
     #description_transaction = browser.span(class: 'uilist__item__label').text
     #puts description_transaction
     #date_transaction = browser.span(class: 'uilist__item__detail').text
     #puts date_transaction
     #возвращаемся назад к списку транзакции
     #
     browser.back
     #скролим вниз сайта чтобы можно было бы кликнуть по любой транзакции
     while browser.text.include?("No more activity")==false do
       browser.scroll.to :bottom
     end
  end
end


puts "------------------------------------------------------------------------------------"
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

puts "------------------------------------------------------------------------------------"
js =array_accaunts.map(&:to_h).to_json

puts js
puts "------------------------------------------------------------------------------------"

