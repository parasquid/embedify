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

    # check if the opengraph object is complete
    unless opengraph.valid?
      # the opengraph object is lacking some mandatory attributes
      attributes = OpenGraph::Object::MANDATORY_ATTRIBUTES
      attributes.delete 'url'
      attributes.each do |attribute|
        self.send(attribute.to_sym, opengraph)
      end
    end
    opengraph
  end

  private

  def self.title(document)
    document['title'] = document[:nokogiri_parsed_document].css('title').first.inner_text
  end

  def self.type(document)
    document['type'] = 'website'
  end

  def self.image(document)
    puts "image"
  end

end