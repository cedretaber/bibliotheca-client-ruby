module BibliothecaClient
  module Response
    Success = Struct.new(:status, :body)
    Error = Struct.new(:status, :message)
  end
end
