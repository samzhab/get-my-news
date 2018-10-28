#!/usr/bin/env ruby
require 'json'
require 'addressable'
require 'rest-client'
require 'byebug'
require 'pdfkit'
require 'nokogiri'
require File.expand_path('get_ip_info.rb')
# ----------------------------------------------------------------------------
class GetMyNews
  LANGUAGE = %w[
    ar de en es fr he it nl
    no pt ru se ud zh
  ].freeze

  CATEGORY = %w[
    business entertainment general health science
    sports technology
  ].freeze

  COUNTRY = %w[
    ae ar at au be bg br ca ch cn co
    cu cz de eg fr gb gr hk hu id ie il
    in it jp kr lt lv ma mx my ng nl no
    nz ph pl pt ro rs ru sa se sg si sk
    th tr tw ua us ve za
  ].freeze

  SORT = %w[
    popularity publishedAt
  ].freeze

  def start
    puts '[newsapi] GET YOUR NEWS FREAKING FAST'
    puts '[newsapi] ENTER YOU APIKEY'
    api_key = gets.chomp
    puts '[newsapi] ENTER YOUR QUERY OPTIONS SEPARATED BY A COMMA'
    puts '[newsapi] FORMAT country,category,keyword'
    puts '[newsapi] eg. de,business,xrp'
    puts '[newsapi] eg. us,sports,boxing'
    puts '[newsapi] eg. health,brain'
    puts '[newsapi] eg. fifa'
    search = gets.chomp
    search = search.split(',')
    query = "#{setup_query(search)}apiKey=#{api_key}"
    news_items = get_my_news(query)
    get_ip_obj = GetIpInfo.new
    if !news_items.nil?
      news_items.each do |article|
        ip_info = get_ip_obj.start(article['url'])
        article.merge!(ip_info)
        write_brief_news_to_pdf(article)
        # write_articles_to_pdf(article)
      end
    else
      puts '[newsapi] NO RESULTS FOUND'
    end
  end

  def get_my_news(query)
    response = get_request(query)
    news_items = []
    begin
      json = JSON.parse(response.body)
      if json['status'] == 'ok' && !json['totalResults'].zero?
        json['articles'].each do |item|
          article = {}
          article['soure_name'] = item['source']['name']
          article['published_at'] = item['publishedAt']
          article['content'] = item['content']
          article['url'] = item['url']
          news_items << article
          # article['author']
          # article['title']
          # article['description']
          # article['url']
          # article['urlToImage']
          # article['publishedAt']
          # article['content']
        end
        return news_items
      elsif json['status'] == 'ok' && json['totalResults'].zero?
        # no results found
      end
    rescue JSON::ParserError => e
      puts e
      return nil
    end
  end

  def write_articles_to_pdf(article)
    response = get_request(article['url'])
    sleep 1
    html = response.body
    html_to_pdf(html, article)
    html = add_ip_info_to_html(response,article)
    html_to_pdf(html, article, 'ip-info-added')
  end

  def write_brief_news_to_pdf(article)
    html = construct_brief_news_html(article)
    html_to_pdf(html, article)
  end

  def construct_brief_news_html(article)
    html_template_file = 'html5_template'
    template_path  = Dir.pwd + '/template_files/' + html_template_file + '.html'
    html_template  = File.read(template_path)
    doc = Nokogiri::HTML(html_template)
    ip_info = Nokogiri::XML::Node.new "div", doc
    line_break = Nokogiri::XML::Node.new "div", doc
    brief_article_content = Nokogiri::XML::Node.new "div", doc
    ip_info.content = "ipInfo >>>
                      city: #{article['city']}
                      country: #{article['country']}
                      isp: #{article['isp']}
                      lat:#{article['lat']} long:#{article['lon']}
                      org: #{article['org']} ip:#{article['query']}
                      region: #{article['regionName']} zip: #{article['zip']}
                      "
    line_break.content = "-----------------------------------------------------"
    brief_article_content.content = "#{article['content']}"
    doc.at("body").add_child(brief_article_content)
    doc.at("body").add_child(line_break)
    doc.at("body").add_child(ip_info)

    doc.to_html
  end

  def add_ip_info_to_html(response,article)
    doc = Nokogiri::XML(response.body)
    ip_info = Nokogiri::XML::Node.new "ip_info", doc
    ip_info.content = "#{article['as']} city: #{article['city']}
                      country: #{article['country']}
                      isp: #{article['isp']}
                      lat:#{article['lat']} long:#{article['lon']}
                      org: #{article['org']} ip:#{article['query']}
                      region: #{article['regionName']} zip: #{article['zip']}"
   # doc.at("document").add_child(ip_info)
   if doc.at("title")
     doc.at("title").add_child(ip_info)
   elsif doc.at("head")
     doc.at("head").add_child(ip_info)
   elsif doc.at("body")
     doc.at("body").add_child(ip_info)
   end
   doc.to_html
  end

  def setup_query(search)
    puts '[newsapi] CHOOSE YOUR OPTION'
    puts '[newsapi] 1 - GET TOP HEADLINES'
    puts '[newsapi] 2 - GET EVERYTHING'
    # puts '[newsapi] 3 - GET SOURCES'
    option = gets.chomp
    query = assign_query_type(search, option)
    if search
      search.each do |search_item|
        term_type = check_term_type(search_item)
        query = update_query(query, term_type, search_item)
        # if search_item.split(":") # if can be splited further
        #   container = []
        #   term_type = nil
        #   terms = search_item.split(":")
        #   terms.each do |term|
        #     term_type = check_term_type(term)
        #     container << collect_terms(query, term_type, term)
        #   end
        #   query = update_query(query, term_type, container)
        # else # one search item
        #   term_type = check_term_type(search_item)
        # end
      end
    end
    query
  end

  def update_query(query, term_type, search_item)
    "#{query}#{term_type}=#{search_item}&"
  end

  def assign_query_type(search, option)
    option = option.to_i
    return 'https://newsapi.org/v2/top-headlines?' if option == 1
    return 'https://newsapi.org/v2/everything?' if option == 2
    return 'https://newsapi.org/v2/top-headlines' if search.nil && option == 1
    return 'https://newsapi.org/v2/everything' if search.nil && option == 2
  end

  def check_term_type(term)
    if CATEGORY.include?(term)
      'category'
    elsif COUNTRY.include?(term)
      'country'
    elsif LANGUAGE.include?(term)
      'language'
    elsif SORT.include?(term)
      'sortBy'
    # :NOTE implement date from to
    else # it is a keyword to search for
      'q'
    end
  end

  def collect_terms(_query, term_type, term)
    if term_type == 'category'
      container << term
    elsif term_type == 'language'
      container << term
    elsif term_type == 'country'
      container << term
    end
  end

  def html_to_pdf(html, article)
    # grab html title or domain name and use for file name
    # change to pdf and save to file
    file_name = article['soure_name'].to_s.gsub(' ','-')
    pub_date_time = article['published_at']
    PDFKit.new(html).to_file("articles\/#{file_name}#{pub_date_time}.pdf")
    # PDFKit.new(html).to_file("articles\/#{file_name}#{additional_info}.pdf")
  end

  def get_request(url)
    response = RestClient::Request.execute(method: :get, url: Addressable::URI
                                             .parse(url) .normalize.to_str,
                                           timeout: 5)
    response
  end
end

freaking_fast_news = GetMyNews.new
freaking_fast_news.start
