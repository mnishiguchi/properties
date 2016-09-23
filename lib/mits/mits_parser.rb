require "active_support/all"
require "awesome_print"
require "hashie"
require "pry"


=begin
The MitsParser module helps us extract from parsed feed information that we want.
---
Usage:
  # Create a MitsParser representation of all the properties.
  @mits_query = MitsParser::Properties.from(mits_data)

  NOTE: Data must not include the root key, namely "PhysicalProperty".
=end


class Hash
  include Hashie::Extensions::DeepFind
  include Hashie::Extensions::DeepLocate
end


class MitsParser

  def initialize(mits_data)
    unless mits_data.is_a?(Array) || mits_data.is_a?(Hash)
      raise "data must be array or hash"
    end

    # Store the passed-in mits data.
    @data = mits_data

    # Create a MitsParser representation of all the properties.
    @mit_parser_properties = MitsParser::Properties.from(@data)
  end


  def parse
    @mit_parser_properties.map { |property| formatted_attributes_for(property) }
  end


  class << self

    # Returns array of values.
    def deep_find_all_by_key(data, key)
      return unless data
      data.deep_find_all(key)
    end


    # Returns array of key-value pairs(hashes).
    def deep_locate_all_by_key(data, key)
      return unless data
      data.deep_locate -> (k, v, object) { k == key && v.present? }
    end
  end


  # =======================================================
  # Find all the properties here.
  # =======================================================


  class Properties

    # Retuens an array of MitsParser::Property objects, which is generated
    # based on the passed-in feed data.
    def self.from(data)
      results = []

      ["Property", "property"].each do |key|
        results << MitsParser.deep_find_all_by_key(data, key)
      end

      results = results.flatten.uniq
      results = results.map { |property| MitsParser::Property.new(property) }
    end
  end


  # =======================================================
  # Find useful inforamtion for a property here.
  # =======================================================


  # Represents a single property. Finds data for each field of our property schema.
  # ---
  # Usage:
  #   MitsParser::Property.new(property).address

  class Property

    def initialize(property_data)
      @property = property_data
    end


    # Returns all the values for the specified keys.
    def find_all_by_keys(*search_keys)
      results = []

      search_keys.each do |key|
        results << MitsParser.deep_find_all_by_key(@property, key)
      end

      results = results.flatten.uniq.compact
    end


    # ---
    # Finders for individual fields.
    # NOTE: Must return an array of all data that were found.
    # ---


    def identification
      results = find_all_by_keys("Identification").compact.uniq
    end

    def information
      results = find_all_by_keys("Information").compact.uniq
    end

    def policy
      results = find_all_by_keys("Policy").compact.uniq
    end

    def floorplans
      results = find_all_by_keys("Floorplans").compact.uniq
    end

    def amenities
      results = find_all_by_keys("Amenities").compact.uniq
    end

    def file
      results = find_all_by_keys("File").compact.uniq
    end
  end


  private


  # =======================================================
  # Structure a property hash to be outputted here.
  # =======================================================


    # Takes a MitsParser::Property object that represents a SINGLE property.
    def formatted_attributes_for(mits_parser_property)
      unless mits_parser_property.is_a?(MitsParser::Property)
        raise ArgumentError.new("mits_parser_property must be a MitsParser::Property")
      end


      # ---
      # Step 1: Format/sanitize things.
      # ---

      # Get copies of the info at the major nodes.
      identification = mits_parser_property.identification
      information    = mits_parser_property.information
      policy         = mits_parser_property.policy
      floorplans     = mits_parser_property.floorplans
      amenities      = mits_parser_property.amenities
      file           = mits_parser_property.file


      # ---
      # Step 2: Create a hash in our desired format and return it.
      # ---


      {
        # :raw_hash     => @data,

         :identification => identification,
         :information    => information,
         :policy         => policy,
         :floorplans     => floorplans,
         :amenities      => amenities,
         :file           => file,
      }
    end
end
