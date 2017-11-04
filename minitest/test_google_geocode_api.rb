require File.expand_path(File.dirname(__FILE__) + '/../test/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../test/http_request')

require 'minitest/autorun'
require 'test_helper'
require 'json_expressions/minitest'

class GoogleGeocodeApiTest < Minitest::Test
  include HttpRequestTestHelper

  WebMock.allow_net_connect!

  # The below tests check geocode and reverse geocode results
  #
  # Additionally, I created tests that will verify a specfic address is associated with the correct reverse geocode (and visa versa)
  #
  # Because the invalid responses that I would get from this API varied based on whether I exceeded the number of requests (or, possibly, if I had already submitted
  # an erroneous request), I don't have specific tests to verify a 404 response.
  #
  # The last test in this suite (test_get_geocode_response_body_elements) verifies each element within the JSON response. I included this type of test, depending on if
  # the business would find capturing that level of detail useful. Additionally, that type of request could be scaled to other test GET requests based on very specific
  # parameters.

  def setup
    super
    @base_url = "https://maps.googleapis.com/maps/api/geocode/json"
    @api_key = "key=AIzaSyC8TPOW-55dcfdOmiGAUwyd5-gqhQYdy1E"
    # Geocode and Reverse Geocode values for Github US office
    @geocode_full_address = "address=88%20Colin%20P%20Kelly%20Jr%20St%2C%20San%20Francisco%2C%20CA&sensor=false&#{@api_key}"
    @geocode_street_wo_number = "address=Colin%20P%20Kelly%20Jr%20St%2C%20San%20Francisco%2C%20CA&sensor=false&#{@api_key}"
    @geocode_city_state = "address=San%20Francisco%2C%20CA&sensor=false&#{@api_key}"
    @geocode_state = "CA&sensor=false&#{@api_key}"
    @geocode_address_invalid = "address=Z12345%20Colin%20P%20Kelly%20Jr%20St%2C%20San%20Francisco%2C%20CA&sensor=false"
    @reverse_geocode = "latlng=37.78226710000001,-122.3912479"
    @geocode_invalid_uri = "http://maps.googleapis.com/maps/api/geo/json?address=88%20Colin%20P%20Kelly%20Jr%20St%2C%20San%20Francisco%2C%20CA&sensor=false"
    @reverse_geocode_invalid_lat = "https://maps.googleapis.com/maps/api/geocode/json?latlng=37.7822671#0000001,-122.3912479&key=AIzaSyC8TPOW-55dcfdOmiGAUwyd5-gqhQYdy1E"
    # Additional URL query parameters
    @country_us = "components=country:US"
    @place_id_us = "place_id=ChIJCzYy5IS16lQRQrfeQ5K5Oxw"
    @country_uk = "components=country:UK"
    @place_id_uk = "place_id=ChIJqZHHQhE7WgIReiWIMkOg-MQ"
  end

  def test_get_geocode_full_street_address
    valid_geocode_request = @base_url+"?"+@geocode_full_address+"&"+@api_key
    server_response = http_request(:get, valid_geocode_request)

    response_body = server_response.body
    formatted_address = JSON.parse(response_body)["results"][0]["formatted_address"]
    status = JSON.parse(response_body)["status"]
        assert_requested(:get, valid_geocode_request, times: 1)
        assert_equal "88 Colin P Kelly Jr St, San Francisco, CA 94107, USA", formatted_address
        assert_equal "OK", status
  end

  def test_get_geocode_no_street_number
    valid_geocode_request = @base_url+"?"+@geocode_street_wo_number+"&"+@api_key
    server_response = http_request(:get, valid_geocode_request)

    response_body = server_response.body
    formatted_address = JSON.parse(response_body)["results"][0]["formatted_address"]
    status = JSON.parse(response_body)["status"]
    assert_requested(:get, valid_geocode_request, times: 1)
    assert_equal "Colin P Kelly Jr St, San Francisco, CA 94107, USA", formatted_address
    assert_equal "OK", status
  end

  # Asserts the formatted address is returned w/o the street number, street name, nor zip code
  def test_get_geocode_city_state
    valid_geocode_request = @base_url+"?"+@geocode_city_state+"&"+@api_key
    server_response = http_request(:get, valid_geocode_request)

    response_body = server_response.body
    formatted_address = JSON.parse(response_body)["results"][0]["formatted_address"]
    status = JSON.parse(response_body)["status"]
    assert_requested(:get, valid_geocode_request, times: 1)
    assert_equal "San Francisco, CA, USA", formatted_address
    assert_equal "OK", status
  end

  def test_get_reverse_geocode
    valid_reverse_geocode_request = @base_url+"?"+@reverse_geocode+"&"+@api_key
    server_response = http_request(:get, valid_reverse_geocode_request)
    response_body = server_response.body

    formatted_address = JSON.parse(response_body)["results"][1]["formatted_address"]
    lat = JSON.parse(response_body)["results"][1]["geometry"]["location"]["lat"]
    long = JSON.parse(response_body)["results"][1]["geometry"]["location"]["lng"]
    status = JSON.parse(response_body)["status"]
    assert_requested(:get, valid_reverse_geocode_request, times: 1)
    assert_equal "88 Colin P Kelly Jr St, San Francisco, CA 94107, USA", formatted_address
    assert_equal "37.78226710000001".to_f, lat
    assert_equal "-122.3912479".to_f, long
    assert_equal "OK", status
  end

  def test_get_geocode_domestic_country
    valid_geocode_request = @base_url+"?"+@country_us+"&"+@api_key
    server_response = http_request(:get, valid_geocode_request)

    response_body = server_response.body
    long_name = JSON.parse(response_body)["results"][0]["address_components"][0]["long_name"]
    short_name = JSON.parse(response_body)["results"][0]["address_components"][0]["short_name"]
    formatted_address = JSON.parse(response_body)["results"][0]["formatted_address"]
    place_id = JSON.parse(response_body)["results"][0]["place_id"]
    status = JSON.parse(response_body)["status"]
    assert_requested(:get, valid_geocode_request, times: 1)
    assert_equal "United States", long_name
    assert_equal "US", short_name
    assert_equal "United States", formatted_address
    assert_equal "ChIJCzYy5IS16lQRQrfeQ5K5Oxw", place_id
    assert_equal "OK", status
  end

  def test_get_geocode_domestic_place_id
    valid_geocode_request = @base_url+"?"+@place_id_us+"&"+@api_key
    server_response = http_request(:get, valid_geocode_request)

    response_body = server_response.body
    long_name = JSON.parse(response_body)["results"][0]["address_components"][0]["long_name"]
    short_name = JSON.parse(response_body)["results"][0]["address_components"][0]["short_name"]
    formatted_address = JSON.parse(response_body)["results"][0]["formatted_address"]
    place_id = JSON.parse(response_body)["results"][0]["place_id"]
    status = JSON.parse(response_body)["status"]
    assert_requested(:get, valid_geocode_request, times: 1)
    assert_equal "United States", long_name
    assert_equal "US", short_name
    assert_equal "United States", formatted_address
    assert_equal "ChIJCzYy5IS16lQRQrfeQ5K5Oxw", place_id
    assert_equal "OK", status
  end

  def test_get_geocode_international_country
    valid_geocode_request = @base_url+"?"+@country_uk+"&"+@api_key
    server_response = http_request(:get, valid_geocode_request)

    response_body = server_response.body
    long_name = JSON.parse(response_body)["results"][0]["address_components"][0]["long_name"]
    short_name = JSON.parse(response_body)["results"][0]["address_components"][0]["short_name"]
    formatted_address = JSON.parse(response_body)["results"][0]["formatted_address"]
    place_id = JSON.parse(response_body)["results"][0]["place_id"]
    status = JSON.parse(response_body)["status"]
    assert_requested(:get, valid_geocode_request, times: 1)
    assert_equal "United Kingdom", long_name
    assert_equal "GB", short_name
    assert_equal "United Kingdom", formatted_address
    assert_equal "ChIJqZHHQhE7WgIReiWIMkOg-MQ", place_id
    assert_equal "OK", status
  end

  def test_get_geocode_international_place_id
    valid_geocode_request = @base_url+"?"+@place_id_uk+"&"+@api_key
    server_response = http_request(:get, valid_geocode_request)

    response_body = server_response.body
    long_name = JSON.parse(response_body)["results"][0]["address_components"][0]["long_name"]
    short_name = JSON.parse(response_body)["results"][0]["address_components"][0]["short_name"]
    formatted_address = JSON.parse(response_body)["results"][0]["formatted_address"]
    place_id = JSON.parse(response_body)["results"][0]["place_id"]
    status = JSON.parse(response_body)["status"]
    assert_requested(:get, valid_geocode_request, times: 1)
    assert_equal "United Kingdom", long_name
    assert_equal "GB", short_name
    assert_equal "United Kingdom", formatted_address
    assert_equal "ChIJqZHHQhE7WgIReiWIMkOg-MQ", place_id
    assert_equal "OK", status
  end

  # Assert that each element within the get geocode response matches what is expected
  def test_get_geocode_response_body_elements
    valid_geocode_request = @base_url+"?"+@geocode_full_address+"&"+@api_key
    server_response = http_request(:get, valid_geocode_request)
    pattern =  {
        results: [
            {
                address_components: [
                    {
                        long_name: "88",
                        short_name: "88",
                        types: [
                            "street_number"
                        ]
                    },
                    {
                        long_name: "Colin P Kelly Junior Street",
                        short_name: "Colin P Kelly Jr St",
                        types: [
                            "route"
                        ]
                    },
                    {
                        long_name: "South of Market",
                        short_name: "South of Market",
                        types: [
                            "neighborhood",
                            "political"
                        ]
                    },
                    {
                        long_name: "San Francisco",
                        short_name: "SF",
                        types: [
                            "locality",
                            "political"
                        ]
                    },
                    {
                        long_name: "San Francisco County",
                        short_name: "San Francisco County",
                        types: [
                            "administrative_area_level_2",
                            "political"
                        ]
                    },
                    {
                        long_name: "California",
                        short_name: "CA",
                        types: [
                            "administrative_area_level_1",
                            "political"
                        ]
                    },
                    {
                        long_name: "United States",
                        short_name: "US",
                        types: [
                            "country",
                            "political"
                        ]
                    },
                    {
                        long_name: "94107",
                        short_name: "94107",
                        types: [
                            "postal_code"
                        ]
                    }
                ],
                formatted_address: "88 Colin P Kelly Jr St, San Francisco, CA 94107, USA",
                geometry: {
                    location: {
                        lat: 37.78226710000001,
                        lng: -122.3912479
                    },
                    location_type: "ROOFTOP",
                    viewport: {
                        northeast: {
                            lat: 37.78361608029151,
                            lng: -122.3898989197085
                        },
                        southwest: {
                            lat: 37.78091811970851,
                            lng: -122.3925968802915
                        }
                    }
                },
                place_id: "ChIJU-lq_neAhYAR9LiPJPEp-Bw",
                types: [
                    "street_address"
                ]
            }
        ],
        status: "OK"
    }

    # Assert the expected JSON pattern elements matches the server response elements
    assert_json_match pattern, server_response.body
  end

end