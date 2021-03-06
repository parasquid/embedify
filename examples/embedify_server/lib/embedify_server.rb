$LOAD_PATH << File.expand_path('../../lib')

require 'sinatra/base'
require 'sinatra/synchrony'
require "sinatra/jsonp"
require 'json'
require 'cgi'
require 'em-synchrony'
require 'em-synchrony/em-http'
require 'embedify'

Faraday.default_adapter = :em_synchrony

class EmbedifyServer < Sinatra::Base

  register Sinatra::Synchrony

  helpers Sinatra::Jsonp
  enable :sessions
  set :session_secret, "My session secret"

  def self.get_or_post(url,&block)
    get(url,&block)
    post(url,&block)
  end

  get_or_post '/' do
    puts "processing #{params[:url]}"

    properties = Embedify.fetch(CGI::escape(params[:url]))

    # we don't want to return the nokogiri doc
    properties.delete :nokogiri_parsed_document

    session[:properties] = properties

    puts "returning #{properties.to_json}"

    headers 'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => '*',
      'Access-Control-Allow-Headers' => '*'
    content_type 'application/json'
    jsonp properties.to_json, params[:callback] || :callback
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

end
