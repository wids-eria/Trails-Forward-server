module ResourceTileZoning
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def valid_zone_types
      [:residential, :none, :protected]
    end

    # to map from import csv
    def zone_type
      @zone_type ||= {
        12 => :residential,
        13 => :residential,
        14 => :residential,
        15 => :residential
      }
      @zone_type.default = :none
      @zone_type
    end
  end
end
