require 'nokogiri'
require 'faraday'
require 'hashie'

module Embedify

  # Fetch Open Graph data from the specified URI. Makes an
  # HTTP GET request and returns an OpenGraph::Object
  def self.fetch(uri, options = {})
    opengraph = begin
      html = Faraday.get(uri)
      page = parse(html.body)
      page['url'] = uri unless page.include? 'url'
      page
    rescue Exception => e
      raise e
    end

    # check if the opengraph object is complete
    unless opengraph.valid?
      # the opengraph object is lacking some mandatory attributes
      attributes = Embedify::Object::MANDATORY_ATTRIBUTES
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

  def self.parse(html)
    doc = Nokogiri::HTML.parse(html)
    page = Embedify::Object.new
    doc.css('meta').each do |m|
      if m.attribute('property') && m.attribute('property').to_s.match(/^og:(.+)$/i)
        page[$1.gsub('-','_')] = m.attribute('content').to_s
      end
    end
    page[:nokogiri_parsed_document] = doc
    page
  end

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



  TYPES = {
    'activity' => %w(activity sport),
    'business' => %w(bar company cafe hotel restaurant),
    'group' => %w(cause sports_league sports_team),
    'organization' => %w(band government non_profit school university),
    'person' => %w(actor athlete author director musician politician public_figure),
    'place' => %w(city country landmark state_province),
    'product' => %w(album book drink food game movie product song tv_show),
    'website' => %w(blog website)
  }

  # The OpenGraph::Object is a Hash with method accessors for
  # all detected Open Graph attributes.
  class Object < Hashie::Mash
    MANDATORY_ATTRIBUTES = %w(title type image url)

    # The object type.
    def type
      self['type']
    end

    # The schema under which this particular object lies. May be any of
    # the keys of the TYPES constant.
    def schema
      Embedify::TYPES.each_pair do |schema, types|
        return schema if types.include?(self.type)
      end
      nil
    end

    Embedify::TYPES.values.flatten.each do |type|
      define_method "#{type}?" do
        self.type == type
      end
    end

    Embedify::TYPES.keys.each do |scheme|
      define_method "#{scheme}?" do
        self.type == scheme || Embedify::TYPES[scheme].include?(self.type)
      end
    end

    # If the Open Graph information for this object doesn't contain
    # the mandatory attributes, this will be <tt>false</tt>.
    def valid?
      MANDATORY_ATTRIBUTES.each{|a| return false unless (self[a] && !self[a].empty?)}
      true
    end
  end

end
