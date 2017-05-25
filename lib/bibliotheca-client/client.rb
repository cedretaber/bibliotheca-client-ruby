
require "uri"
require "json"

require "bibliotheca-client/http"
require "bibliotheca-client/paths"
require "bibliotheca-client/response"
require "bibliotheca-client/book/book"
require "bibliotheca-client/user/user"

module BibliothecaClient
  class Client

    @@bibliotheca_url = URI.parse ENV["BIBLIOTHECA_URL"]
    @@auth_header = ENV["BIBLIOTHECA_AUTH_HEADER"] || "Authorization"
    @@logger = Logger.new($stdout)

    def initialize(token, url = @@bibliotheca_url, auth_header = @@auth_header)
      @http_client = HTTP.new(url, token, auth_header)
    end

    def logout
      delete Paths::LOGOUT
    end

    def ping
      get Paths::PING
    end

    ## User API

    def user_index
      get Paths::Users::INDEX
    end

    def user_create(param)
      post Paths::Users::CREATE, param
    end

    def user_show(id)
      get Paths::Users::SHOW.(id)
    end

    def user_update(id, param)
      put Paths::Users::UPDATE.(id), param
    end

    def user_delete(id)
      delete Paths::Users::DELETE.(id)
    end

    def user_book_lent(id, book_id)
      get Paths::Users::Books::LENT.(id, book_id)
    end

    def user_book_back(id, book_id)
      delete Paths::Users::Books::BACK.(id, book_id)
    end

    ## Book API

    def book_search(query)
      get Paths::Books::SEARCH + "?q=#{query}"
    end

    def book_insert(param)
      post Paths::Books::INSERT, param
    end

    def book_remove(id)
      delete Paths::Books::REMOVE.(id)
    end

    def book_lend(id)
      get Paths::Books::LEND.(id)
    end

    def book_back(id)
      delete Paths::Books::BACK.(id)
    end

    class << self
      def login(email, password, url = nil, auth_header = nil)
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

        case res = HTTP.post_without_auth(url, { email: email, password: password }.to_json)
        when Net::HTTPNoContent
          res[auth_header]
        else
          @@logger.error(__FILE__) { "login fail.\nstatus: #{res.status}\nbody: #{res.body}" }
          nil
        end
      end

      def session(email, password, url = nil, auth_header = nil)
        return unless block_given?

        token = login(email, password, url, auth_header)
        client = Client.new(token, url, auth_header)

        begin
          yield client
        ensure
          client.logout
        end
      end

      def config(url: nil, auth_header: nil, logger: nil)
        @@bibliotheca_url = URI.parse url if url
        @@auth_header = auth_header if auth_header
        @@logger = logger if logger
      end
    end

    private

    def get(url)
      handle_response @http_client.get(url)
    end

    def post(url, body)
      handle_response @http_client.post(url, body.to_json)
    end

    def put(url, body)
      handle_response @http_client.put(url, body.to_json)
    end

    def delete(url)
      handle_response @http_client.delete(url)
    end

    def handle_response(res)
      case res
      when Net::HTTPSuccess
        Response::Success(res.status, res.body.empty? ? nil : JSON.parse(res.body))
      else
        Response::Error(res.status, res.body.empty? ? nil : JSON.parse(res.body))
      end
    end
  end

  def self.config(**confs)
    Client.config(**confs)
  end
end
