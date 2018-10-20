#!/usr/bin/env ruby
require 'json'
require 'addressable'
require 'rest-client'
require 'byebug'

class GetIpInfo
  def start(site)
    query = setup_ip_query(clean(site))
    response = get_request(query) # max of 150 requests per minute
    process_json_response(response.body)
  end

  def clean(site)
    site[/((www)?\.?\w+\.\w+)/]
  end

  def setup_ip_query(url)
    "http://ip-api.com/json/#{url}"
  end

  def process_json_response(response)
    JSON.parse(response)
  end

  def get_request(url)
    response = RestClient::Request.execute(method: :get, url: Addressable::URI
                                             .parse(url) .normalize.to_str,
                                           timeout: 5)
    response
  end
end
