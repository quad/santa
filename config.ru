require 'sequel'

Sequel.connect ENV['DATABASE_URL'] || 'sqlite://development.db'

require './santa'

run Santa
