require "test/unit"
require "json"

require "./test/helper/with_server"

require "bibliotheca-client/client"

class TestOperations < Test::Unit::TestCase
  extend WithServer

  setup do
    @auth_header = Bibliotheca::Client.class_variable_get(:@@auth_header)
    Bibliotheca::Client.config url: "http://#{server.address}:#{server.port}"

    @token = "valid_token"
    @client = Bibliotheca::Client.new @token

    @iv_token = "invalid_token"
    @iv_client = Bibliotheca::Client.new @iv_token
  end

  test "logout" do
    lmd = -> req, res {
      if req[@auth_header] == @token
        res.status = 204
      else
        res.status = 400
      end
    }

    server.with_mount(Bibliotheca::Paths::LOGOUT, lmd) do
      res = @client.logout
      assert res.success?

      res = @iv_client.logout
      assert_false res.success?
    end
  end

  test "ping" do
    lmd = -> _, res {
      res.status = 204
    }

    server.with_mount(Bibliotheca::Paths::PING, lmd) do
      res = @client.ping
      assert res.success?

      res = @iv_client.ping
      assert res.success?
    end
  end
end
