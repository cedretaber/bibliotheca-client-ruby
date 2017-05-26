require_relative "./../test_helper"
require_relative "./../helpers/with_server"

require "test/unit"
require "json"

require "bibliotheca-client/client"

class TestClient < Test::Unit::TestCase
  extend WithServer

  test "create client with default settings." do
    token = "dummy"
    client = Bibliotheca::Client.new(token)
    http = client.instance_variable_get(:@http_client)

    assert_equal http.instance_variable_get(:@url_base), Bibliotheca::Client.class_variable_get(:@@bibliotheca_url)
    assert_equal http.instance_variable_get(:@auth_header), Bibliotheca::Client.class_variable_get(:@@auth_header)
    assert_equal http.instance_variable_get(:@token), token
  end

  test "change config." do
    url = "http://example.com"
    header = "Test-Header"
    Bibliotheca.config(
      url: url,
      auth_header: header
    )

    token = "dummy"
    client = Bibliotheca::Client.new(token)
    http = client.instance_variable_get(:@http_client)

    require "uri"

    assert_equal http.instance_variable_get(:@url_base), URI.parse(url)
    assert_equal http.instance_variable_get(:@auth_header), header
    assert_equal http.instance_variable_get(:@token), token
  end

  test "change config by Client class." do
    url = "http://example.com"
    header = "Test-Header"
    Bibliotheca::Client.config(
      url: url,
      auth_header: header
    )

    token = "dummy"
    client = Bibliotheca::Client.new(token)
    http = client.instance_variable_get(:@http_client)

    require "uri"

    assert_equal http.instance_variable_get(:@url_base), URI.parse(url)
    assert_equal http.instance_variable_get(:@auth_header), header
    assert_equal http.instance_variable_get(:@token), token
  end

  test "login" do
    req_email = "test@example.com"

    valid_password = "valid_password"
    invalid_password = "invalid_password"

    Bibliotheca::Client.config url: "http://#{server.address}:#{server.port}"
    auth_header = Bibliotheca::Client.class_variable_get(:@@auth_header)
    token = "valid_token"

    lmd = -> req, res {
      params = JSON.parse req.body
      email, password = %w(email password).map { |key| params[key] }
      if email == req_email
        case password
        when valid_password
          res.status = 204
          res[auth_header] = token
        when invalid_password
          res.status = 401
        else
          res.status = 404
        end
      else
        res.status = 404
      end
    }

    server.with_mount(Bibliotheca::Paths::LOGIN, lmd) do
      res = Bibliotheca::Client.login(req_email, valid_password)
      assert_equal res, token

      res = Bibliotheca::Client.login(req_email, invalid_password)
      assert_nil res
    end
  end

  test "login with custom string url." do
    req_email = "test@example.com"
    valid_password = "valid_password"
    auth_header = Bibliotheca::Client.class_variable_get(:@@auth_header)
    token = "valid_token"

    lmd = -> req, res {
      params = JSON.parse req.body
      email, password = %w(email password).map { |key| params[key] }
      if email == req_email && password == valid_password
        res.status = 204
        res[auth_header] = token
      else
        res.status = 404
      end
    }

    server.with_mount(Bibliotheca::Paths::LOGIN, lmd) do
      url = "http://#{server.address}:#{server.port}"

      res = Bibliotheca::Client.login req_email, valid_password, url: url
      assert_equal res, token
    end
  end

  test "login with custom URI url." do
    req_email = "test@example.com"
    valid_password = "valid_password"
    auth_header = Bibliotheca::Client.class_variable_get(:@@auth_header)
    token = "valid_token"

    lmd = -> req, res {
      params = JSON.parse req.body
      email, password = %w(email password).map { |key| params[key] }
      if email == req_email && password == valid_password
        res.status = 204
        res[auth_header] = token
      else
        res.status = 404
      end
    }

    server.with_mount(Bibliotheca::Paths::LOGIN, lmd) do
      url = URI.parse "http://#{server.address}:#{server.port}"

      res = Bibliotheca::Client.login req_email, valid_password, url: url
      assert_equal res, token
    end
  end

  test "login with custom header" do
    req_email = "test@example.com"
    valid_password = "valid_password"

    Bibliotheca::Client.config url: "http://#{server.address}:#{server.port}"
    auth_header = "Custom-Auth-Header"
    token = "valid_token"

    lmd = -> req, res {
      params = JSON.parse req.body
      email, password = %w(email password).map { |key| params[key] }
      if email == req_email && password == valid_password
        res.status = 204
        res[auth_header] = token
      else
        res.status = 404
      end
    }

    server.with_mount(Bibliotheca::Paths::LOGIN, lmd) do
      res = Bibliotheca::Client.login req_email, valid_password, auth_header: auth_header
      assert_equal res, token
    end
  end

  test "session" do
    req_email = "test@example.com"
    valid_password = "valid_password"
    invalid_password = "invalid_password"

    Bibliotheca::Client.config url: "http://#{server.address}:#{server.port}"
    auth_header = Bibliotheca::Client.class_variable_get(:@@auth_header)
    token = "valid_token"
    call_count = 0

    server.server.mount_proc Bibliotheca::Paths::LOGIN, -> req, res {
      params = JSON.parse req.body
      email, password = %w(email password).map { |key| params[key] }
      if email == req_email && password == valid_password
        res.status = 204
        res[auth_header] = token
      else
        res.status = 404
      end
    }
    server.server.mount_proc Bibliotheca::Paths::LOGOUT, -> req, res {
      if req[auth_header] == token
        call_count += 1
        res.status = 204
      else
        res.status = 403
      end
    }

    begin
      Bibliotheca::Client.session req_email, valid_password do |client|
        assert_equal token, client.instance_variable_get(:@http_client).instance_variable_get(:@token)
      end
      sleep 1
      assert_equal 1, call_count

      Bibliotheca::Client.session req_email, invalid_password do
        assert false
      end
      assert_equal call_count, 1
    ensure
      server.server.unmount Bibliotheca::Paths::LOGOUT
      server.server.unmount Bibliotheca::Paths::LOGIN
    end
  end
end
