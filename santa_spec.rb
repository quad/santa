require 'minitest/autorun'
require 'rack/test'
require 'sequel'

db = Sequel.connect 'sqlite://test.db'

Sequel.extension :migration
Sequel::IntegerMigrator.new(db, 'migrations').run

module TransactionalTestCase
  def run *args
    [].tap do |rv|
      Sequel::Model.db.transaction(:rollback => :always) { rv << super(*args) }
    end.pop
  end
end

require './santa'

set :environment, :test

describe Santa do
  include TransactionalTestCase
  include Rack::Test::Methods

  let(:app) { Santa }

  let(:ih) { 'abc123' }
  let(:dn) { 'lulz.mp3 torrent' }

  it 'should post a new torrent' do
    put '/', [{ih: ih, dn: dn}].to_json

    assert last_response.ok?
    Torrent[info_hash: ih].wont_be_nil
  end

  it 'should show posted torrents' do
    Torrent.create info_hash: ih, display_name: dn

    get '/'

    assert last_response.ok?
    parsed_response = JSON.parse last_response.body
    parsed_response.must_equal [{'ih' => ih, 'dn' => dn}]
  end
end
