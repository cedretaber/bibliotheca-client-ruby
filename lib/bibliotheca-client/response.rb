module BibliothecaClient
  module Response
    Success = Struct.new(:data)
    Error = Struct.new(:status, :message)
  end
end
