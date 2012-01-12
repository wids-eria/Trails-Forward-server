module TrailsForward
  module MongoSpacial
    extend ActiveSupport::Concern

    included do
      include Mongoid::Spacial::Document

      field :location, type: Array, spacial: true
      spacial_index :location
      before_save :set_location

      def set_location
        self.location = [x,y]
      end
    end
  end
end
