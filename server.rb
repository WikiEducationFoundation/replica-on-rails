require 'sinatra'
require_relative './replica.rb'

get '/' do
  'Ohai'
end

before do
  content_type 'application/json', 'charset' => 'utf-8'
end

after do
  Replica.close_connection
end

get '/:database/:username/:start/:end/revisions.json' do
  Replica.connect(database: params['database'])
  result = Actor.find_by(actor_name: params['username'])
                .revisions.joins(:page)
                .where(rev_timestamp: params['start']..params['end'])
                .pluck(:page_title, :page_namespace, :rev_page, :rev_timestamp)
  result.to_json
end

post '/:database/revisions.json' do
  puts params
  Replica.connect(database: params['database'])
  post_params = JSON.parse(request.body.read)
  puts post_params
  result = Revision.where(actor: Actor.where(actor_name: post_params['usernames']))
                   .where(rev_timestamp: post_params['start']..post_params['end'])
                   .joins(:page, :actor)
                   .pluck(:page_title, :page_namespace, :actor_name, :rev_page, :rev_timestamp)
  { 'data' => result.map do |rev|
      {
        'page_title' => rev[0].force_encoding('utf-8'),
        'page_namespace' => rev[1],
        'actor_name' => rev[2].force_encoding('utf-8'),
        'rev_page' => rev[3],
        'rev_timestamp' => rev
      }
    end
  }.to_json
end

get '/:database/last_article.json' do
  Replica.connect(database: params['database'])
  result = Page.last.to_json
  result
end
