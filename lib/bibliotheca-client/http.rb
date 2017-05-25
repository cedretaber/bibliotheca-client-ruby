require "net/http"
require "uri"

module BibliothecaClient
  class HTTP
    def self.post_without_auth(url, body)
      req = Net::HTTP::Post.new(url.path)
      req["Content-Type"] = "application/json"
      req.body = body

      Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }
    end

    def initialize(url_base, token, auth_header)
      @url_base = url_base
      @token = token
      @auth_header = auth_header
    end

    def get(url)
      request Net::HTTP::Get.new(@url_base + url.path)
    end

    def post(url, body)
      request_with_body Net::HTTP::Post.new(@url_base + url.path), body
    end

    def put(url, body)
      request_with_body Net::HTTP::Put.new(@url_base + url.path), body
    end

    def delete(url)
      request Net::HTTP::Delete.new(@url_base + url.path)
    end

    private

    def request(req)
      req[@auth_header] = @token

      Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }
    end

    def request_with_body(req, body)
      req["Content-Type"] = "application/json"
      req.body = body

      request req
    end
  end
end
