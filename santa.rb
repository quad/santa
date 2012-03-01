require 'json'
require 'sequel'
require 'sinatra'

class Torrent < Sequel::Model; end

class Santa < Sinatra::Application
  put '/' do
    parsed_request = JSON.parse request.body.read
    parsed_request.each do |torrent|
      ih = torrent['ih']
      dn = torrent['dn']

      Torrent.find_or_create(info_hash: ih) do |t|
        t.info_hash = ih
        t.display_name = dn
      end
    end

    'OK'
  end

  get '/' do
    Torrent.all.map do |t|
      {
        ih: t.info_hash,
        dn: t.display_name,
      }
    end.to_json
  end
end
