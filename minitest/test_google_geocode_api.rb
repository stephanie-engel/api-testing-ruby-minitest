require File.expand_path(File.dirname(__FILE__) + '/../test/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../test/http_request')

require 'minitest/autorun'
require 'test_helper'

class GoogleGeocodeApiTest < Minitest::Test
  include HttpRequestTestHelper

  WebMock.allow_net_connect!

  def setup
    super
    @geocode_valid = "http://maps.googleapis.com/maps/api/geocode/json?address=88%20Colin%20P%20Kelly%20Jr%20St%2C%20San%20Francisco%2C%20CA&sensor=false"
    @geocode_invalid_uri = "http://maps.googleapis.com/maps/api/geo/json?address=88%20Colin%20P%20Kelly%20Jr%20St%2C%20San%20Francisco%2C%20CA&sensor=false"
    @geocode_invalid_address = "http://maps.googleapis.com/maps/api/geo/json?address=12345%20Colin%20P%20Kelly%20Jr%20St%2C%20San%20Francisco%2C%20CA&sensor=false"
    @reverse_geocode_valid = "https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=AIzaSyC8TPOW-55dcfdOmiGAUwyd5-gqhQYdy1E"
    @reverse_geocode_invalid_uri = "https://maps.googleapis.com/maps/api/geo/json?latlng=40.714224,-73.961452&key=AIzaSyC8TPOW-55dcfdOmiGAUwyd5-gqhQYdy1E"
    @reverse_geocode_invalid_address = "https://maps.googleapis.com/maps/api/geo/json?latlng=40.714224,-73.961452&key=AIzaSyC8TPOW-55dcfdOmiGAUwyd5-gqhQYdy1E"
  end

  def test_get_geocode_valid
    http_request(:get, @geocode_valid)
    assert_requested(:get, @geocode_valid, times: 1)
    assert_requested(:get, @geocode_valid)
  end

  def test_get_geocode_invalid_uri
      http_request(:get, @geocode_invalid_uri)
      assert_not_requested(:get, @geocode_valid)
  end

  def test_get_geocode_invalid_address
    http_request(:get, @geocode_invalid_address)
    assert_not_requested(:get, @geocode_valid)
  end

  def test_get_reverse_geocode_valid
    http_request(:get, @reverse_geocode_valid)
    assert_requested(:get, @reverse_geocode_valid, times: 1)
    assert_requested(:get, @reverse_geocode_valid)
  end

  def test_get_reverse_geocode_invalid_uri
    http_request(:get, @reverse_geocode_invalid_uri)
    assert_not_requested(:get, @reverse_geocode_valid)
  end

  def test_get_reverse_geocode_invalid_address
    http_request(:get, @reverse_geocode_invalid_address)
    assert_not_requested(:get, @reverse_geocode_valid)
  end

  # def test_response_body_elements
  #   #requests_per_minute = hash["metric_data"]["metrics"][0]["timeslices"][0]["values"]["requests_per_minute"]
  #   response = http_request(:get, @geocode_valid)
  #   hash = JSON.parse(response.body)
  #   puts hash
  # end
  #
  # def test_response_ok
  #   #requests_per_minute = hash["metric_data"]["metrics"][0]["timeslices"][0]["values"]["requests_per_minute"]
  #   response = http_request(:get, "https://api.github.com/")
  #   hash = JSON.parse(response.body)
  #   puts hash
  #   hash.assert_includes(:key => "current_user_url")
  # end

  # { name: 'Rob', years: '28' }.assert_valid_keys(:name, :age) # => raises "ArgumentError: Unknown key: :years. Valid keys are: :name, :age"
  # { name: 'Rob', age: '28' }.assert_valid_keys('name', 'age') # => raises "ArgumentError: Unknown key: :name. Valid keys are: 'name', 'age'"
  # { name: 'Rob', age: '28' }.assert_valid_keys(:name, :age)   # => passes, raises nothing

end