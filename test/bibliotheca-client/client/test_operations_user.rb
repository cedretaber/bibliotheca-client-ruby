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

    time = Time.new(2016, 4, 1, 12, 0)
    @user1 = Bibliotheca::User.new(1, "user1@example.com", nil, "ADMIN", time, time)
    @user2 = Bibliotheca::User.new(2, "user2@example.com", nil, "ADMIN", time, time)
    @user3 = Bibliotheca::User.new(3, "user3@example.com", nil, "ADMIN", time, time)
  end

  test "user_index" do
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 200
        res.body = {
          users: [
            @user1, @user2, @user3
          ].map { |user|
            {
              id: user.id,
              email: user.email,
              authCode: user.auth_code,
              insertedAt: user.created_at,
              updatedAt: user.updated_at
            }
          }
        }.to_json
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Users::INDEX, lmd) do
      res = @client.user_index
      assert res.success?
      assert_equal res.data, [@user1, @user2, @user3]

      res = @iv_client.user_index
      assert_false res.success?
    end
  end

  test "user_create" do
    password = "p@ssw0rd"
    user = @user1.clone
    user.password = password

    lmd = -> req, res {
      if req[@auth_header] == @token
        params = (JSON.parse req.body)["user"]

        if params["email"] == @user1.email && params["password"] == password && @user1.auth_code == params["auth_code"]
          res.status = 200
          res.body = {
            user: {
              id: user.id,
              email: user.email,
              authCode: user.auth_code,
              insertedAt: user.created_at,
              updatedAt: user.updated_at
            }
          }.to_json
        else
          res.status = 400
        end
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Users::CREATE, lmd) do
      res = @client.user_create user
      assert res.success?
      assert_equal res.data, @user1

      res = @iv_client.user_create user
      assert_false res.success?
    end
  end

  test "user_show" do
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 200
        res.body = {
          user: {
            id: @user1.id,
            email: @user1.email,
            authCode: @user1.auth_code,
            insertedAt: @user1.created_at,
            updatedAt: @user1.updated_at
          }
        }.to_json
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Users::SHOW.(@user1.id), lmd) do
      res = @client.user_show @user1.id
      assert res.success?
      assert_equal res.data, @user1

      res = @iv_client.user_show @user1.id
      assert_false res.success?
    end
  end

  test "user_update" do
    password = "p@ssw0rd"
    user = @user1.clone
    user.password = password

    lmd = -> req, res {
      if req[@auth_header] == @token
        params = (JSON.parse req.body)["user"]

        if params["email"] == @user1.email && params["password"] == password && @user1.auth_code == params["auth_code"]
          res.status = 200
          res.body = {
            user: {
              id: user.id,
              email: user.email,
              authCode: user.auth_code,
              insertedAt: user.created_at,
              updatedAt: user.updated_at
            }
          }.to_json
        else
          res.status = 400
        end
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Users::UPDATE.(@user1.id), lmd) do
      res = @client.user_update @user1.id, user
      assert res.success?
      assert_equal res.data, @user1

      res = @iv_client.user_update @user1.id, user
      assert_false res.success?
    end
  end

  test "user_delete" do
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 204
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Users::DELETE.(@user1.id), lmd) do
      res = @client.user_delete @user1.id
      assert res.success?

      res = @iv_client.user_delete @user1.id
      assert_false res.success?
    end
  end

  test "user_book_lend" do
    book_id = 42
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 204
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Users::Books::LEND.(@user1.id, book_id), lmd) do
      res = @client.user_book_lend @user1.id, book_id
      assert res.success?

      res = @iv_client.user_book_lend @user1.id, book_id
      assert_false res.success?
    end
  end

  test "user_book_back" do
    book_id = 42
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 204
      else
        res.status = 403
      end
    }

    server.with_mount(Bibliotheca::Paths::Users::Books::BACK.(@user1.id, book_id), lmd) do
      res = @client.user_book_back @user1.id, book_id
      assert res.success?

      res = @iv_client.user_book_back @user1.id, book_id
      assert_false res.success?
    end
  end
end
