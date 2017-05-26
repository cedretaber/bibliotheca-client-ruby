require "time"

module Bibliotheca
  USER_ATTRIBUTES = %i(id email password auth_code created_at updated_at).freeze

  class User < Struct.new *USER_ATTRIBUTES
    def self.from_hash(json)
      User.new(
        json["id"],
        json["email"],
        nil,
        json["authCode"],
        (Time.parse json["insertedAt"] rescue nil),
        (Time.parse json["updatedAt"] rescue nil)
      )
    end
  end
end
