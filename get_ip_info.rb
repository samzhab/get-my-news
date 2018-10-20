#!/usr/bin/env ruby
require 'json'
require 'addressable'
require 'rest-client'
require 'byebug'

class GetIpInfo
  def start(site)
    query = setup_ip_query(clean(site))
    response = get_request(query) # max of 150 requests per minute
    json_response = process_json_response(response.body)
    return json_response if json_response['status'] == 'success'
  end

  def clean(site)
    site = site[/^https?((www|.+)?\.?\w+\.[a-zA-Z]+)\/\b/].split("//")
    site[1] = site[1].to_s.gsub("/","")
    site
  end

  def setup_ip_query(url)
    "http://ip-api.com/json/#{url[1]}"
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
