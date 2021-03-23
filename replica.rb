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
      encoding: 'utf8',
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

  has_many :revisions, foreign_key: 'rev_page'

  def page_title
    self[:page_title].force_encoding('utf-8')
  end
end

class Actor < ActiveRecord::Base
  self.table_name = 'actor'
  self.primary_key = 'actor_id'

  has_many :revisions, foreign_key: 'rev_actor'

  def actor_name
    self[:actor_name].force_encoding('utf-8')
  end
end

class Revision < ActiveRecord::Base
  self.table_name = 'revision_userindex'
  self.primary_key = 'rev_id'

  has_one :parent_revision, class_name: 'Revision', foreign_key: 'rev_parent_id'
  belongs_to :page, foreign_key: 'rev_page'
  belongs_to :actor, foreign_key: 'rev_actor'
end
