module BibliothecaClient
  ATTRIBUTES = %i(email password auth_code).freeze

  class User < Struct.new *ATTRIBUTES
  end
end
