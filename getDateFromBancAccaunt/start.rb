#autor: SergheiScepanovschi
#ver 3.3
require 'date'
require 'watir'
require 'webdrivers'
require 'faker'
require 'rubygems'
require 'json'

class Transaction
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
  def initialize(_carrierName)
    @carrierName        = _carrierName       #имя владельца
  end
  def exec
    puts @carrierName
  end
end
class Accaunt
  def initialize(_nameAccaunt, _currency, _availableBalance, _classification,_carrierName)
    @nameAccaunt      = _nameAccaunt      #имя
    @currency         = _currency         #валюта
    @availableBalance = _availableBalance #баланс
    @classification   = _classification   #природа
    @card             = Card.new(_carrierName)          #карты
    @transaction      = Transaction.new("31.12.2020","Магазин",-32)      #транзакции
  end
  def exec
    puts @nameAccaunt, @currency, @availableBalance, @classification
    @transaction.exec
    @card.exec
  end
end

browser = Watir::Browser.new :chrome
#заходим на сайт
browser.goto "https://demo.bendigobank.com.au/banking/sign_in"
#кликаем на кнопку входа
browser.button(:name => "customer_type").click
#копируем необходимые данные
strct = browser.script(:id => "data").innertext

puts strct
#Находим данные
pos1 = strct.rindex(/__DATA__/)
# Выделяем строку с данными
strct1 = strct.slice(pos1+10,13897) # я пока не знаю как получить положение третьего переноса строки
puts strct1
#здесь при парсинге JSON возникает ошибка из-за лишних символов в строке
#my_hash = JSON.parse(strct1)
#puts my_hash["name"] #пример того как можно получить значени из распарсенной строки
# пример того как будет заполнятся оьект класса
accaunt = Accaunt.new("DailyAcc", "MDL", 1213123123,"Debit","Anton Pirojkov")
accaunt.exec
