require "webrick"

module WEBrick
module HTTPServlet
class ProcHandler
  alias do_PUT    do_POST
  alias do_DELETE do_GET
end
end
end
