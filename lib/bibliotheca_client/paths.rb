module BibliothecaClient
  module Paths
    set_consts(
      self,
      LOGIN: "/api/login",
      LOGOUT: "/api/logout",
      PING: "/api/ping"
    )

    module Users
      ::Paths.set_consts(
        self,
        INDEX: "/api/users",
        CREATE: "/api/users/",
        SHOW: -> id { "/api/users/#{id}" },
        UPDATE: -> id { "/api/users/#{id}" },
        DELETE: -> id { "/api/users/#{id}" }
      )

      module Books
        ::Paths.set_consts(
          self,
          LEND: -> id, book_id { "/api/users/#{id}/books/lend/#{book_id}" },
          BACK: -> id, book_id { "/api/users/#{id}/books/back/#{book_id}" }
        )
      end
    end

    module Books
      ::Paths.set_consts(
        self,
        SEARCH: "/api/search/",
        INSERT: "/api/books/",
        DETAIL: -> id { "/api/books/#{id}" },
        REMOVE: -> id { "api/books/#{id}" },
        LEND: -> id { "api/books/lend/#{id}" },
        BACK: -> id { "api/books/back/#{id}" }
      )
    end

    private

    def self.set_consts(context, consts)
      consts.each do |name, value|
        context.const_set(name, value.freeze)
      end
    end
  end
end
