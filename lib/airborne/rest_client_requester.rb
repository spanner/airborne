require 'rest_client'

module Airborne
  module RestClientRequester
    def make_request(method, url, options = {})
      base_headers = Airborne.configuration.headers || {}
      options[:headers] ||= {}
      options[:headers].reverse_merge!(base_headers).merge!({content_type: :json})
      options[:url]= get_url(url)
      options[:method] = method
      if method == :post || method == :patch || method == :put
        options[:payload] ||= options[:body] || ""
        options[:payload] = options[:payload].to_json if options[:payload].is_a?(Hash)
      end
      begin
        res = RestClient::Request.new(options).execute()
        res
      rescue RestClient::Exception => e
        e.response
      end
    end
  end
end