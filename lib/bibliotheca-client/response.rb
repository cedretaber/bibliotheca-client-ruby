module Bibliotheca
  module Response
    class  Success < Struct.new(:data)
      def success?
        true
      end
    end
    class Error < Struct.new(:status, :message)
      def success?
        false
      end
    end
  end
end
