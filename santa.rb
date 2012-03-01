require 'json'
require 'sequel'
require 'sinatra'

class Torrent < Sequel::Model; end

TRACKERS = [
  'udp://tracker.publicbt.com:80/announce',
  'udp://tracker.openbittorrent.com:80/announce',
]

class Santa < Sinatra::Application
  put '/' do
    parsed_request = JSON.parse request.body.read
    parsed_request.each do |torrent|
      ih, dn = torrent['ih'].to_s, torrent['dn'].to_s
      return 400 unless ih =~ /^[0-9a-fA-F]{40}$/
      return 400 if dn.empty?

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
        tr: TRACKERS,
      }
    end.to_json
  end
end
