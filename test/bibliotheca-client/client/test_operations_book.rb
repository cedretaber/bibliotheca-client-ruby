require_relative "./../../test_helper"
require_relative "./../../helpers/with_server"

require "test/unit"
require "json"

require "bibliotheca-client/client"

class TestOperationsUser < Test::Unit::TestCase
  extend WithServer

  setup do
    @auth_header = Bibliotheca::Client.class_variable_get(:@@auth_header)
    Bibliotheca::Client.config url: "http://#{server.address}:#{server.port}"

    @token = "valid_token"
    @client = Bibliotheca::Client.new @token

    @iv_token = "invalid_token"
    @iv_client = Bibliotheca::Client.new @iv_token

    date = Date.new(2010, 10, 18)
    time = Time.new(2016, 4, 1, 12, 0)
    @book1 = Bibliotheca::Book.new(
      1, "book1", "a first book.", ["author11", "author12"], "Cop1 co., ltd.",
      "http://example.com/img1.png", "1234567890001", 334, date, time
    )
    @book2 = Bibliotheca::Book.new(
      2, "book2", "a seconds book.", ["author21", "author22"], "Cop2 co., ltd.",
      "http://example.com/img2.png", "1234567890001", 991, date, time
    )
    @book3 = Bibliotheca::Book.new(
      3, "book3", "a third book.", ["author31", "author32"], "Cop3 co., ltd.",
      "http://example.com/img3.png", "1234567890001", 893, date, time
    )
  end

  test "book_search with q." do
    q = "book"
    lmd = -> req, res {
      if req[@auth_header] == @token && req.query["q"] == q
        res.status = 200
        res.body = {
          books: [
            @book1, @book2, @book3
          ].map { |book|
            {
              id: book.id,
              title: book.title,
              description: book.description,
              authors: book.authors,
              publisher: book.publisher,
              imageUrl: book.image_url,
              isbn: book.isbn,
              pageCount: book.page_count,
              publishedAt: book.published_at,
              insertedAt: book.created_at
            }
          }
        }.to_json
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Books::SEARCH, lmd) do
      res = @client.book_search q
      assert res.success?
      assert_equal res.data, [@book1, @book2, @book3]

      res = @iv_client.book_search q
      assert_false res.success?
    end
  end

  test "book_insert" do
    lmd = -> req, res {
      if req[@auth_header] == @token
        params = (JSON.parse req.body)["book"]

        if %w(title description authors publisher image_url isbn page_count).all? { |key|
             params[key] == eval("@book1.#{key}")
           } && params["published_at"] == @book1.published_at.to_s
          res.status = 200
          res.body = {
            book: {
              id: @book1.id,
              title: @book1.title,
              description: @book1.description,
              authors: @book1.authors,
              publisher: @book1.publisher,
              imageUrl: @book1.image_url,
              isbn: @book1.isbn,
              pageCount: @book1.page_count,
              publishedAt: @book1.published_at,
              insertedAt: @book1.created_at
            }
          }.to_json
        else
          res.status = 400
        end
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Books::INSERT, lmd) do
      res = @client.book_insert @book1
      assert res.success?
      assert_equal res.data, @book1

      res = @iv_client.book_insert @book1
      assert_false res.success?
    end
  end

  test "book_detail" do
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 200
        res.body = {
          book: {
            id: @book1.id,
            title: @book1.title,
            description: @book1.description,
            authors: @book1.authors,
            publisher: @book1.publisher,
            imageUrl: @book1.image_url,
            isbn: @book1.isbn,
            pageCount: @book1.page_count,
            publishedAt: @book1.published_at,
            insertedAt: @book1.created_at
          }
        }.to_json
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Books::DETAIL.(@book1.id), lmd) do
      res = @client.book_detail @book1.id
      assert res.success?
      assert_equal res.data, @book1

      res = @iv_client.book_detail @book1.id
      assert_false res.success?
    end
  end

  test "book_remove" do
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 204
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Books::REMOVE.(@book1.id), lmd) do
      res = @client.book_remove @book1.id
      assert res.success?

      res = @iv_client.book_remove @book1.id
      assert_false res.success?
    end
  end

  test "book_lend" do
    book_id = 42
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 204
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Books::LEND.(book_id), lmd) do
      res = @client.book_lend book_id
      assert res.success?

      res = @iv_client.book_lend book_id
      assert_false res.success?
    end
  end

  test "book_back" do
    book_id = 42
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 204
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Books::BACK.(book_id), lmd) do
      res = @client.book_back book_id
      assert res.success?

      res = @iv_client.book_back book_id
      assert_false res.success?
    end
  end
end
