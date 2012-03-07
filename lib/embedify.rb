$:.unshift(File.expand_path(File.dirname(__FILE__))) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'nokogiri'
require 'httparty'
require 'opengraph'

module Embedify

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

    # fill in extra attributes
    unless opengraph.include? 'description'
      self.description(opengraph)
    end
    opengraph
  end

  private

  def self.title(document)
    document['title'] ||= document[:nokogiri_parsed_document].css('title').first.inner_text
  end

  def self.type(document)
    document['type'] ||= 'website'
  end

  def self.image(document)
    # TODO: loop through all images and bring back up to 30 good candidates
    # Good candidates: at least 50x50, max aspect ratio of 3:1, png/jpeg/gif format
    puts "image"
  end

  def self.description(document)
    meta_tags = document[:nokogiri_parsed_document].css('meta')
    meta_tags.each do |meta_tag|
      if meta_tag.attribute('name').to_s.match(/^description$/i)
        document['description'] = meta_tag.attribute('content').to_s
        return
      end
    end

    # TODO: make the description be the first few words of the first <p></p>
    document['description'] = ''
  end

end