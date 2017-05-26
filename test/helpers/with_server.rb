require_relative "./patch_webrick"

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

    begin
      yield
    ensure
      server.unmount path
    end
  end

  def self.extended(test_class)
    test_class.class_eval do
      def server
        self.class
      end
    end
  end
end
