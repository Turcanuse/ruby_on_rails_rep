#autor: SergheiScepanovschi
#ver 3.0
require 'date'
require 'watir'
require 'webdrivers'
require 'faker'
require 'rubygems'

class Transaction
  def initialize(_date, _description, _amount)
    @date        = _date         #Дата
    @description = _description  #описание
    @amount      = _amount       #сумма
  end
end

class Card
  def initialize(_carrierName)
    @carrierName        = _carrierName       #имя владельца
  end
end
class Accaunt
  def initialize(_nameAccaunt, _currency, _availableBalance, _classification,_card, _transaction )
    @nameAccaunt      = _nameAccaunt      #имя
    @currency         = _currency         #валюта
    @availableBalance = _availableBalance #баланс
    @classification   = _classification   #природа
    @card             = _card             #карты
    @transaction      = _transaction      #транзакции
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