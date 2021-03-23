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
                   .pluck(:rev_page, :page_title, :page_namespace, :rev_id, :rev_timestamp, :actor_name, :actor_user, :rev_parent_id)
  {
    'success' => true,
    'data' => result.map do |rev|
      {
        'page_id' => rev[0],
        'page_title' => rev[1].force_encoding('utf-8'),
        'page_namespace' => rev[2],
        'rev_id' => rev[3],
        'rev_timestamp' => rev[4],
        'rev_user_text' => rev[5].force_encoding('utf-8'),
        'system' => false, # TODO
        'rev_user' => rev[6],
        'new_article' => rev[7] == 0,
        'byte_change' => 0 # TODO
      }
    end
  }.to_json
end

get '/:database/last_article.json' do
  Replica.connect(database: params['database'])
  result = Page.last.to_json
  result
end

# https://wikiedudashboard.toolforge.org/revisions.php?lang=en&project=wikipedia&usernames[]=Gwilliams06&oauth_tags[]=OAuth+CID%3A+1232&start=20190101003430&end=20190126003430
# { "success": true, "data": [{"page_id":"59761232","page_title":"Gwilliams06","page_namespace":"2","rev_id":"880033399","rev_timestamp":"20190124221927","rev_user_text":"Gwilliams06","rev_user":"35693273","system":"true","new_article":"true","byte_change":"167"},{"page_id":"59761233","page_title":"Gwilliams06","page_namespace":"3","rev_id":"880033401","rev_timestamp":"20190124221928","rev_user_text":"Gwilliams06","rev_user":"35693273","system":"true","new_article":"true","byte_change":"169"},{"page_id":"59761234","page_title":"Gwilliams06\/sandbox","page_namespace":"2","rev_id":"880033404","rev_timestamp":"20190124221928","rev_user_text":"Gwilliams06","rev_user":"35693273","system":"true","new_article":"true","byte_change":"33"},{"page_id":"59104148","page_title":"Wiki_Ed\/Fisk_University\/CORE_160-05_(Spring_2019)","page_namespace":"4","rev_id":"880033410","rev_timestamp":"20190124221929","rev_user_text":"Gwilliams06","rev_user":"35693273","system":"true","new_article":"false","byte_change":"36"}] }
