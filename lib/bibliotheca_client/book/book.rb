module BibliothecaClient
  ATTRIBUTES = %i(
    title
    description
    authors
    publisher
    published_at
    page_count
    isbn
  ).freeze

  class Book < Struct.new *ATTRIBUTES
  end
end
