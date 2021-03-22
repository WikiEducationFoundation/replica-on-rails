require 'active_record'
require 'mysql2'
require 'yaml'

credentials = YAML.load(File.open('cnf.yml').read)
USERNAME = credentials['user']
PASSWORD = credentials['password']

class Replica
  def new(database)
    
  end
  
  def open_connection
    ActiveRecord.establish_connection(
      adapter: 'mysql',
      database: "enwiki_p",
      encoding: 'utf8',
      host: 'enwiki.analytics.db.svc.wikimedia.cloud',
      username: USERNAME,
      password: PASSWORD
    )
  end

  def close_connection
    ActiveRecord::Base.connection.close
  end

  def query
  end
end

class Article < ActiveRecord::Base
end
