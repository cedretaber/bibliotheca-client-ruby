
require "logger"
require "uri"
require "json"

require "bibliotheca-client/http"
require "bibliotheca-client/paths"
require "bibliotheca-client/response"
require "bibliotheca-client/book/book"
require "bibliotheca-client/user/user"

module BibliothecaClient
  class Client

    @@bibliotheca_url = URI.parse ENV["BIBLIOTHECA_URL"] || "http://localhost:4000"
    @@auth_header = ENV["BIBLIOTHECA_AUTH_HEADER"] || "Authorization"
    @@logger = Logger.new($stdout)

    def initialize(token, url = @@bibliotheca_url, auth_header = @@auth_header)
      @http_client = HTTP.new(url, token, auth_header)
    end

    def logout
      handle_no_content delete Paths::LOGOUT
    end

    def ping
      handle_no_content get Paths::PING
    end

    ## User API

    def user_index
      handle_users get Paths::Users::INDEX
    end

    def user_create(param)
      handle_user post Paths::Users::CREATE, to_user_param(param)
    end

    def user_show(id)
      handle_user get Paths::Users::SHOW.(id)
    end

    def user_update(id, param)
      handle_user put Paths::Users::UPDATE.(id), to_user_param(param)
    end

    def user_delete(id)
      handle_no_content delete Paths::Users::DELETE.(id)
    end

    def user_book_lent(id, book_id)
      handle_no_content get Paths::Users::Books::LENT.(id, book_id)
    end

    def user_book_back(id, book_id)
      handle_no_content delete Paths::Users::Books::BACK.(id, book_id)
    end

    ## Book API

    def book_search(query)
      handle_books get Paths::Books::SEARCH + "?q=#{URI.encode query}"
    end

    def book_detail(id)
      handle_book get Paths::Books::DETAIL.(id)
    end

    def book_insert(param)
      handle_book post Paths::Books::INSERT, to_book_param(param)
    end

    def book_remove(id)
      handle_no_content delete Paths::Books::REMOVE.(id)
    end

    def book_lend(id)
      handle_no_content get Paths::Books::LEND.(id)
    end

    def book_back(id)
      handle_no_content delete Paths::Books::BACK.(id)
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
      @http_client.get(@@bibliotheca_url + url)
    end

    def post(url, body)
      @http_client.post(@@bibliotheca_url + url, body.to_json)
    end

    def put(url, body)
      @http_client.put(@@bibliotheca_url + url, body.to_json)
    end

    def delete(url)
      @http_client.delete(@@bibliotheca_url + url)
    end

    def handle_book(res)
      if res.is_a? Net::HTTPOK
        book = Book.from_hash JSON.parse(res.body)["book"]
        Response::Success.new(book)
      else
        handle_error(res)
      end
    end

    def handle_books(res)
      if res.is_a? Net::HTTPOK
        books = JSON.parse(res.body)["books"].map { |book|
          Book.from_hash book
        }
        Response::Success.new(books)
      else
        handle_error(res)
      end
    end

    def handle_user(res)
      if res.is_a? Net::HTTPOK
        user = User.from_hash JSON.parse(res.body)["user"]
        Response::Success.new(user)
      else
        handle_error(res)
      end
    end

    def handle_users(res)
      if res.is_a? Net::HTTPOK
        users = JSON.parse(res.body)["users"].map { |user|
          User.from_hash user
        }
        Response::Success.new(users)
      else
        handle_error(res)
      end
    end

    def handle_no_content(res)
      if res.is_a? Net::HTTPNoContent
        Response::Success.new(nil)
      else
        handle_error(res)
      end
    end

    def handle_error(res)
      # @@logger.error(__FILE__) {
      #   "login fail.\nstatus: #{res.code}\nbody: #{res.body}"
      # }
      Response::Error.new(res.code.to_i, (res.body.empty? ? nil : JSON.parse(res.body) rescue res.body))
    end

    def to_user_param(params)
      to_param(:user, params)
    end

    def to_book_param(params)
      to_params(:book, params)
    end

    def to_param(key, param)
      { key => params.is_a?(Hash) ? params : params.to_h }
    end
  end

  def self.config(**confs)
    Client.config(**confs)
  end
end
