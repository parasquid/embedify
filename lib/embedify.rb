require 'nokogiri'
require 'httparty'
require 'opengraph'

module Embedify

  OPENGRAPH_REGEX = /^og:(.+)$/i

  def self.fetch(uri, options = {})
    begin
      opengraph = OpenGraph.fetch(uri, false)
    rescue SocketError => e
      raise e
    end
    opengraph
  end

  private

end