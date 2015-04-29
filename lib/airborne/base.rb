require 'json'
require 'active_support/hash_with_indifferent_access'

module Airborne
  class InvalidJsonError < StandardError; end
  include RequestExpectations
  def self.configure
    RSpec.configure do |config|
      yield config
    end
  end

  def self.included(base)
    if(!Airborne.configuration.requester_module.nil?)
      base.send(:include, Airborne.configuration.requester_module)
    elsif(!Airborne.configuration.rack_app.nil?)
      base.send(:include, RackTestRequester)
    else
      base.send(:include, RestClientRequester)
    end
  end

  def self.configuration
    RSpec.configuration
  end

  def get(url, headers = nil, ssl_options = {})
    set_response(make_request(:get, url, {headers: headers}.merge(ssl_options)))
  end

  def post(url, post_body = nil, headers = nil, ssl_options = {})
    set_response(make_request(:post, url, {body: post_body, headers: headers}.merge(ssl_options)))
  end

  def patch(url, patch_body = nil, headers = nil, ssl_options = {})
    set_response(make_request(:patch, url, {body: patch_body, headers: headers}.merge(ssl_options)))
  end

  def put(url, put_body = nil, headers = nil, ssl_options = {})
    set_response(make_request(:put, url, {body: put_body, headers: headers}.merge(ssl_options)))
  end

  def delete(url, headers = nil, ssl_options = {})
    set_response(make_request(:delete, url, {headers: headers}.merge(ssl_options)))
  end

  def head(url, headers = nil, ssl_options = {})
    set_response(make_request(:head, url, {headers: headers}.merge(ssl_options)))
  end

  def options(url, headers = nil, ssl_options = {})
    set_response(make_request(:options, url, {headers: headers}.merge(ssl_options)))
  end

  def response
    @response
  end

  def headers
    @headers
  end

  def body
    @body
  end

  def json_body
    raise InvalidJsonError, "Api request returned invalid json" unless @json_body
    @json_body
  end

  private

  def get_url(url)
    base = Airborne.configuration.base_url || ""
    base + url
  end

  def set_response(res)
    @response = res
    @body = res.body
    @headers = HashWithIndifferentAccess.new(res.headers) unless res.headers.nil?
    begin
      @json_body = JSON.parse(res.body, symbolize_names: true) unless res.body.empty?
    rescue
    end
  end
end
