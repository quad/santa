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

  let(:ih) { '0daa24cd1bd8281996125e292e399d9ad46750f9' }
  let(:dn) { 'lulz.mp3 torrent' }

  it 'should post a new torrent' do
    put '/', [{ih: ih, dn: dn}].to_json

    assert last_response.ok?
    Torrent[info_hash: ih].wont_be_nil
  end

  it 'should reject invalid infohashes' do
    [
      'abc123',
      nil,
      '',
      0,
      1.0,
      false,
      '0daa24cd1bd8281996125e292e399d9ad46750f9xxx'
    ].each do |bad_ih|
      put '/', [{ih: bad_ih, dn: dn}].to_json

      refute last_response.ok?, "Accepted invalid infohash: #{bad_ih}"
    end
  end

  it 'should reject invalid display names' do
    [
      nil,
      '',
    ].each do |bad_dn|
      put '/', [{ih: ih, dn: bad_dn}].to_json

      refute last_response.ok?, "Accepted invalid display name: #{bad_dn}"
    end
  end

  it 'should show posted torrents' do
    Torrent.create info_hash: ih, display_name: dn

    get '/'

    assert last_response.ok?
    parsed_response = JSON.parse last_response.body
    parsed_response.must_equal [{'ih' => ih, 'dn' => dn}]
  end
end
