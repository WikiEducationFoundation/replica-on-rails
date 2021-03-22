require 'active_record'
require 'mysql2'
require 'yaml'

credentials = YAML.load(File.open('cnf.yml').read)
USERNAME = credentials['user']
PASSWORD = credentials['password']

class Replica
  def self.connect(database: 'enwiki')
    ActiveRecord::Base.establish_connection(
      adapter: 'mysql2',
      database: "#{database}_p",
      encoding: 'utf8mb4',
      host: "#{database}.analytics.db.svc.wikimedia.cloud",
      username: USERNAME,
      password: PASSWORD
    )
  end

  def self.close_connection
    ActiveRecord::Base.connection.close
  end
end

class Page < ActiveRecord::Base
  self.table_name = 'page'
  self.primary_key = 'page_id'
end


