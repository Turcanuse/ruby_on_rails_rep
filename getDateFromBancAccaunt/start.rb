#autor: SergheiScepanovschi
#ver 3.8
require 'date'
require 'watir'
require 'webdrivers'
require 'faker'
require 'rubygems'
require 'json'
require 'jsonapi-serializers'

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
  attr_accessor :nameAccaunt, :currency, :availableBalance, :classification, :array_card
  def initialize(_nameAccaunt, _currency, _availableBalance, _classification)
    @nameAccaunt       = _nameAccaunt      #имя
    @currency          = _currency         #валюта
    @availableBalance  = _availableBalance #баланс
    @classification    = _classification   #природа
    @array_card        = Array.new         #карты
    #@array_transaction = Array.new         #транзакции
  end
  # Добавляем карту
  def addCard(_carrierName)
    @array_card << Card.new(_carrierName)        #push карты
  end
  #Добавляем транзакцию
  #def addTransaction(_date, _description, _amount)
  #  @array_transaction << Transaction.new(_date, _description, _amount)        #push карты
  #end
  def exec
    puts @nameAccaunt, @currency, @availableBalance, @classification
    #@transaction.exec
    puts "===================="
    for item in @array_card do
      puts  item.exec # не подсвечивает метод
    end
    puts "===================="
  end
end

class AccauntsArray
  def initialize
    @Accaunts        = Array.new         #карты
  end
  def addAccaunt(_nameAccaunt, _currency, _availableBalance, _classification)
    @Accaunts << Accaunt.new(_nameAccaunt, _currency, _availableBalance, _classification)        #push карты
  end

  # добавляем новые элементы массива из JSON hash
  def addAccauntFromHash
    browser = Watir::Browser.new :chrome
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
      self.addAccaunt(item["name"], item["currentBalance"]["currency"], item["currentBalance"]["value"],item["classification"])
      for card in item["cards"] do
        @Accaunts[i].addCard(card["carrierName"])
      end
    i=i+1
    end
  end
end

def to_hash2(obj1)
  Hash[obj1.instance_variables.map { |key|
    variable = obj1.instance_variable_get key
    [key.to_s[1..-1].to_sym,
     if variable.is_a?(Hash) then # проблемное место не понмаю как отличить Hash от обьекта и какието странные адреса в Хэше
       to_hash2(variable)
     else
       variable
     end
    ]
  }]
end

accaunts = AccauntsArray.new()
accaunts.addAccauntFromHash

puts "------------------------------------------------------------------------------------"
hash = to_hash2(accaunts)

puts hash
puts "------------------------------------------------------------------------------------"

