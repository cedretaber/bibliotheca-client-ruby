
require "logger"
require "uri"
require "json"

require "bibliotheca-client/http"
require "bibliotheca-client/paths"
require "bibliotheca-client/response"
require "bibliotheca-client/book"
require "bibliotheca-client/user"
require "bibliotheca-client/client/operations"
require "bibliotheca-client/client/handler"

module Bibliotheca
  class Client

    @@bibliotheca_url = URI.parse ENV["BIBLIOTHECA_URL"] || "http://localhost:4000"
    @@auth_header = ENV["BIBLIOTHECA_AUTH_HEADER"] || "Authorization"
    @@logger = Logger.new($stdout)

    def initialize(token, url = @@bibliotheca_url, auth_header = @@auth_header)
      @http_client = HTTP.new token, url, auth_header
    end

    include Operations
    include Handler

    class << self
      def login(email, password, url: nil, auth_header: nil)
        url = (
          case url
          when String
            URI.parse url
          when URI::HTTP, URI::HTTPS
            url
          else
            @@bibliotheca_url
          end
        ) + Paths::LOGIN

        auth_header = @@auth_header if auth_header.nil?

        res = HTTP.post_without_auth(
          url,
          { email: email, password: password }.to_json
        )

        if res.is_a? Net::HTTPNoContent
          res[auth_header]
        else
          @@logger.error(__FILE__) {
            "login fail.\nstatus: #{res.code}\nbody: #{res.body}"
          }
          nil
        end
      end

      def session(email, password, url = nil, auth_header = nil)
        return unless block_given?

        url ||= @@bibliotheca_url
        auth_header ||= @@auth_header

        if token = login(email, password, url: url, auth_header: auth_header)
          client = Client.new token, url, auth_header

          begin
            yield client
          ensure
            client.logout
          end
        end
      end

      def config(url: nil, auth_header: nil, logger: nil)
        @@bibliotheca_url = URI.parse url if url
        @@auth_header = auth_header if auth_header
        @@logger = logger if logger
      end
    end
  end

  def self.config(**confs)
    Client.config(**confs)
  end
end
