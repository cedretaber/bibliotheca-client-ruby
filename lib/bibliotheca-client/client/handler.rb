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

    %w(Book User).each do |name|
      sym = name.downcase
      klass = Bibliotheca.const_get(name)

      define_method "handle_#{sym}" do |res|
        if res.is_a? Net::HTTPOK
          entity = klass.from_hash JSON.parse(res.body)[sym]
          Response::Success.new entity

        else
          handle_error res
        end
      end

      define_method "handle_#{sym}s" do |res|
        if res.is_a? Net::HTTPOK
          entities = JSON.parse(res.body)["#{sym}s"].map { |entity|
            klass.from_hash entity
          }
          Response::Success.new entities
        else
          handle_error res
        end
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
      to_params(:user, params)
    end

    def to_book_param(params)
      to_params(:book, params)
    end

    def to_params(key, params)
      { key => params.is_a?(Hash) ? params : params.to_h }
    end
  end
end
