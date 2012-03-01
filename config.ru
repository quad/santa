require 'sequel'

db = Sequel.connect ENV['DATABASE_URL'] || 'sqlite://development.db'

# Auto-migrate on connection
Sequel.extension :migration
Sequel::IntegerMigrator.new(db, 'migrations').run

require './santa'

run Santa
