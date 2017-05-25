module BibliothecaClient
  ATTRIBUTES = %i(
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

  class Book < Struct.new *ATTRIBUTES
    def self.from_hash(json)
      Book.new(
        json["id"],
        json["title"],
        json["description"],
        json["authors"],
        json["publisher"],
        json["image_url"],
        json["isbn"],
        json["page_count"],
        json["published_at"],
        json["created_at"]
      )
    end
  end
end
