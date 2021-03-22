require 'sinatra'
require_relative './replica.rb'

get '/' do
  'Ohai'
end

before do
  content_type 'application/json'
end

after do
  Replica.close_connection
end

get '/:database/last_article.json' do
  Replica.connect(database: params['database'])
  result = Page.last.to_json
  result
end
