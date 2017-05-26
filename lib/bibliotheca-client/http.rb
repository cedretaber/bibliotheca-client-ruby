require "net/http"
require "uri"

module Bibliotheca
  class HTTP
    def self.post_without_auth(url, body)
      req = Net::HTTP::Post.new(url.path)
      req["Content-Type"] = "application/json"
      req.body = body

      Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }
    end

    def initialize(token, url_base, auth_header)
      @token = token
      @url_base = url_base
      @auth_header = auth_header
    end

    def get(url)
      request url, Net::HTTP::Get.new(build_url url)
    end

    def post(url, body)
      request_with_body url, Net::HTTP::Post.new(build_url url), body
    end

    def put(url, body)
      request_with_body url, Net::HTTP::Put.new(build_url url), body
    end

    def delete(url)
      request url, Net::HTTP::Delete.new(build_url url)
    end

    private

    def build_url(url)
      (@url_base + url.path).tap { |ret|
        break ret + "?#{url.query}" if url.query
      }
    end

    def request(url, req)
      req[@auth_header] = @token

      Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }
    end

    def request_with_body(url, req, body)
      req["Content-Type"] = "application/json"
      req.body = body

      request url, req
    end
  end
end
