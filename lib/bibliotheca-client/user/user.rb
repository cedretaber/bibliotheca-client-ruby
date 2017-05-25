module BibliothecaClient
  ATTRIBUTES = %i(id email password auth_code created_at updated_at).freeze

  class User < Struct.new *ATTRIBUTES
    def self.from_hash(json)
      User.new(
        json["id"],
        json["email"],
        nil,
        json["auth_code"],
        json["inserted_at"],
        json["updated_at"]
      )
    end
  end
end
