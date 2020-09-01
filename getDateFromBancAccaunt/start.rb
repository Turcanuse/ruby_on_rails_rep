#autor: SergheiScepanovschi
#ver 3.4
require 'date'
require 'watir'
require 'webdrivers'
require 'faker'
require 'rubygems'
require 'json'

class Transaction
  attr_accessor :date, :description, :amount # открываем доступ r/w
  def initialize(_date, _description, _amount)
    @date        = _date         #Дата
    @description = _description  #описание
    @amount      = _amount       #сумма
  end
  def exec
    puts @date, @description, @amount
  end
end

class Card
  attr_accessor :carrierName
  def initialize(_carrierName)
    @carrierName        = _carrierName       #имя владельца
  end
  def exec
    puts @carrierName
  end
end
class Accaunt
  @array_card = Array.new
  def initialize(_nameAccaunt, _currency, _availableBalance, _classification,_carrierName,_carrierName2)
    @nameAccaunt      = _nameAccaunt      #имя
    @currency         = _currency         #валюта
    @availableBalance = _availableBalance #баланс
    @classification   = _classification   #природа
    @array_card       = [Card.new(_carrierName), Card.new(_carrierName2)]        #карты
    @transaction      = Transaction.new("31.12.2020","Магазин",-32)      #транзакции
  end
  def addCard(_carrierName)
    @array_card << Card.new(_carrierName)
  end
  def exec
    puts @nameAccaunt, @currency, @availableBalance, @classification
    #@transaction.exec
    #for item in @array_card do
    #  puts  item.exec # не подсвечивает метод
    #end
  end
end

browser = Watir::Browser.new :chrome
#заходим на сайт
browser.goto "https://demo.bendigobank.com.au/banking/sign_in"
#кликаем на кнопку входа
browser.button(:name => "customer_type").click
#копируем необходимые данные
strct = browser.script(:id => "data").innertext
#Находим данные
pos1 = strct.rindex(/__DATA__/)

#одошол проблему с поиском третьего символа переноса строки нашол другую уникальную позцию
pos2 = strct.rindex(/__BOOTSTRAP_I18N__/)
pos1 =pos1+10
pos2 =pos2-69
# Выделяем строку с данными
strct = strct.slice(pos1,pos2)
puts strct
#здесь при парсинг JSON
my_hash = JSON.parse(strct)

puts "------------------------------------------------------------------------------------"
# создаём оьект класса
array_accaunts = Array.new
for item in my_hash["accounts"] do
  array_accaunts << Accaunt.new(my_hash["accounts"][0]["name"], my_hash["accounts"][0]["currentBalance"]["currency"], my_hash["accounts"][0]["currentBalance"]["value"],my_hash["accounts"][0]["classification"],my_hash["accounts"][0]["cards"][0]["carrierName"],my_hash["accounts"][0]["cards"][1]["carrierName"])
end

for item in array_accaunts do
  puts  item.exec # не подсвечивает метод
  puts "+++++++++++++++++++++++++++++++++++++++++++"
end

#array_accaunts << Accaunt.new(my_hash["accounts"][0]["name"], my_hash["accounts"][0]["currentBalance"]["currency"], my_hash["accounts"][0]["currentBalance"]["value"],my_hash["accounts"][0]["classification"],"Anton Pirojkov","Ivan Ivanich")
#array_accaunts[0].exec
#for item in my_hash["accounts"] do
#  puts  item["name"] # не подсвечивает метод
#end
puts "------------------------------------------------------------------------------------"
#thismonthlist[:Roles].flat_map { |role| role[:admins] }