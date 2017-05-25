require "time"

module BibliothecaClient
  BOOK_ATTRIBUTES = %i(
    id
    title
    description
    authors
    publisher
    image_url
    isbn
    page_count
    published_at
    created_at
  ).freeze

  class Book < Struct.new *BOOK_ATTRIBUTES
    def self.from_hash(json)
      Book.new(
        json["id"],
        json["title"],
        json["description"],
        json["authors"],
        json["publisher"],
        json["imageUrl"],
        json["isbn"],
        json["pageCount"],
        (Date.parse json["publishedAt"] rescue nil),
        (Time.parse json["insertedAt"] rescue nil)
      )
    end
  end
end
