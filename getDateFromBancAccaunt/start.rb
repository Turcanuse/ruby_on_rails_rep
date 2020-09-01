#autor: SergheiScepanovschi
#ver 3.5
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
  def initialize(_nameAccaunt, _currency, _availableBalance, _classification)
    @nameAccaunt      = _nameAccaunt      #имя
    @currency         = _currency         #валюта
    @availableBalance = _availableBalance #баланс
    @classification   = _classification   #природа
    # @array_card  << Card.new(_carrierName)        #карты
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
  array_accaunts << Accaunt.new(item["name"], item["currentBalance"]["currency"], item["currentBalance"]["value"],item["classification"])
  #array_accaunt ,item["cards"][0]["carrierName"],item["cards"][1]["carrierName"]
end

for item in array_accaunts do
  puts  item.exec # не подсвечивает метод
  puts "+++++++++++++++++++++++++++++++++++++++++++"
end
puts "------------------------------------------------------------------------------------"