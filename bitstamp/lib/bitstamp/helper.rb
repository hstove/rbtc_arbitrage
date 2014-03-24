module Bitstamp
  module Helper
    def self.parse_objects!(string, klass)
      # If Bitstamp returned nothing (which it does if the results yield empty) 'cast' it to an array
      string = "[]" if string == ""

      objects = JSON.parse(string)
      objects.collect do |t_json|
        parse_object!(t_json, klass)
      end
    end

    def self.parse_object!(object, klass)
      object = JSON.parse(object) if object.is_a? String

      klass.new(object)
    end
  end
end
