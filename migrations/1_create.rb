Sequel.migration do
  change do
    create_table :torrents do
      primary_key :id

      String :info_hash,
        :size => 40,
        :unique => true
      String :display_name
    end
  end
end
