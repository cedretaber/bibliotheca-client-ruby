module Bibliotheca
  module Operations
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
  end
end
