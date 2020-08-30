#autor: SergheiScepanovschi
#ver 1.0
require 'watir'
require 'webdrivers'
require 'faker'
require 'rubygems'

browser = Watir::Browser.new :chrome
#заходим на сайт
browser.goto "https://demo.bendigobank.com.au/banking/sign_in"
#кликаем на кнопку входа
browser.button(:name => "customer_type").click
#копируем необходимые данные
strct = browser.script(:id => "data").innertext
#"Счета": [
#        "имя": "аккаунт1",
# card
#        «валюта»: «MDL»,
#        «баланс»: 300,22,
#        "природа": "кредитная карта",
#        "транзакции": []
puts strct