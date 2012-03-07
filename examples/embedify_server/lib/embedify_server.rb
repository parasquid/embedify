require 'sinatra/base'

$LOAD_PATH << File.expand_path('~/Sites/opengraph/lib')
$LOAD_PATH << File.expand_path('~/Sites/embedify/lib')

require 'opengraph'
require 'embedify'

class EmbedifyServer < Sinatra::Base

  enable :sessions
  set :session_secret, "My session secret"

  get '/' do
    @properties = session[:properties] || nil
    body = erb :index
    session[:properties] = nil
    body
  end

  post '/' do
    properties = Embedify.fetch(params[:url])

    # we don't want to save the nokogiri doc in the cookie
    properties.delete :nokogiri_parsed_document

    session[:properties] = properties

    redirect '/'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

end