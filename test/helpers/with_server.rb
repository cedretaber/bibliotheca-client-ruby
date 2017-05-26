require "webrick"

module WEBrick
  module HTTPServlet
    class ProcHandler < AbstractServlet
      alias do_PUT    do_POST
      alias do_DELETE do_GET
    end
  end
end

module WithServer

  attr_reader :server, :address, :port

  def startup
    @address = "127.0.0.1"
    @port = 8087
    @server = WEBrick::HTTPServer.new DocumentRoot: ".", BindAddress: @address, Port: @port
    Thread.new do
      @server.start
    end
    sleep 1
  end

  def shutdown
    @server.shutdown
    sleep 1
  end

  def with_mount(path, prc)
    return unless block_given?
    server.mount_proc path, prc

    yield

    server.unmount path
  end

  def self.extended(test_class)
    test_class.class_eval do
      def server
        self.class
      end
    end
  end
end
