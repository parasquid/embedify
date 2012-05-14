require 'nokogiri'
require 'faraday'
require 'hashie'
require "addressable/uri"
require 'fastimage'

module Embedify

  # Fetch Open Graph data from the specified URI. Makes an
  # HTTP GET request and returns an OpenGraph::Object
  def self.fetch(uri, options = {})
    opengraph = begin
      html = get_with_redirects(uri)
      page = parse(html.body)
      page['url'] = html.env[:url].to_s unless page.include? 'url'
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

  def self.get_with_redirects(uri, iterations = 0)
    html = Faraday.get(uri)
    #puts "#{iterations.inspect} #{html.env[:response_headers]['Location']}"
    case html.status
    when  301..307
      html = get_with_redirects(html.env[:response_headers]['Location'], iterations + 1)
    else
      html
    end
  end

  def self.parse(html)
    doc = Nokogiri::HTML.parse(html)
    page = Embedify::Object.new
    
    # capture all og: meta tags
    doc.css('meta').each do |m|
      if m.attribute('property') && m.attribute('property').to_s.match(/^og:(.+)$/i)
        page[$1.gsub('-','_')] = m.attribute('content').to_s
      end
    end
    
    # transform the og:image tag into an array
    unless page.image.nil? || page.image.respond_to?(:each)
      page.image = make_absolute(page.image, page.url || html.env[:url].to_s)
      dimensions = FastImage.size(page.image)
      page.image = [url: page.image, width: dimensions[0], height: dimensions[1]]
    end
    page[:nokogiri_parsed_document] = doc
    page
  end

  def self.title(document)
    unless document['title']
      title_tags = document[:nokogiri_parsed_document].css('title')
      if title_tags.count > 0
        document['title'] = title_tags.first.inner_text
      else
        document.delete 'title'
      end
    end
  end

  def self.type(document)
    document['type'] ||= 'website'
  end

  def self.image(document)
    img_srcs = Set.new
    document[:nokogiri_parsed_document].css('img').each do |img_tag|
      img_srcs.add(make_absolute(img_tag.attribute('src'), document['url']))
    end
    if img_srcs.count > 0
      images = []
      img_src_count = 1
      img_srcs.each do |img_src|
        dimensions = FastImage.size(img_src)
        images.push(url: img_src, width: dimensions[0], height: dimensions[1]) if image_is_big_enough?(dimensions) && image_has_good_proportions?(dimensions)
        img_src_count = img_src_count + 1
        break if(img_src_count > 10)
      end
      document.image = images
    end
  end
  
  def self.make_absolute(href, root)
    URI.parse(root).merge(URI.parse(href)).to_s
  end

  def self.image_is_big_enough?(dimensions)
    return false if dimensions.nil?
    # at least 50x50
    dimensions[0] >= 50 && dimensions[1] >= 50
  end
  
  def self.image_has_good_proportions?(dimensions)
    return false if dimensions.nil?
    # max aspect ratio of 3:1 (one dimension is not more than 3x the other - too narrow/wide in that case)
    (dimensions[0] * 3 >= dimensions[1]) && (dimensions[1] * 3 >= dimensions[0])
  end

  def self.description(document)
    meta_tags = document[:nokogiri_parsed_document].css('meta')
    meta_tags.each do |meta_tag|
      if meta_tag.attribute('name').to_s.match(/^description$/i)
        document['description'] = meta_tag.attribute('content').to_s
        return
      end
    end

    p_tags = document[:nokogiri_parsed_document].css('p')
    if p_tags.count > 0
      document['description'] = p_tags.first.inner_text.to_s
    else
      document.delete 'description'
    end
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
