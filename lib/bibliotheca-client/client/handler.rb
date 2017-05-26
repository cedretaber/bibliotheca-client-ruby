module Bibliotheca
  module Handler

    def self.included(klass)
      @@bibliotheca_url = klass.class_variable_get(:@@bibliotheca_url)
      @@logger = klass.class_variable_get(:@@logger)
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
      @@logger.error(__FILE__) {
        "login fail.\nstatus: #{res.code}\nbody: #{res.body}"
      }
      Response::Error.new(
        res.code.to_i,
        (res.body.empty? ? nil : JSON.parse(res.body) rescue res.body)
      )
    end

    def to_user_param(params)
      to_param(:user, params)
    end

    def to_book_param(params)
      to_params(:book, params)
    end

    def to_param(key, params)
      { key => params.is_a?(Hash) ? params : params.to_h }
    end
  end
end
