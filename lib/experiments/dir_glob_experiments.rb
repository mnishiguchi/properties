require "active_support/all"
require "awesome_print"

# Adopted from Rails
# http://apidock.com/rails/Hash/from_xml/class
def from_xml(xml, disallowed_types = nil)
  ActiveSupport::XMLConverter.new(xml, disallowed_types).to_h
end

# The directory that all the files are stored.
puts "Dir.pwd:  #{Dir.pwd}"
FILE_DIR = "#{Dir.pwd}/test/fixtures/files"

# Obtain all the filenames that match the specified pattern.
json_files = File.join("**", "feed.xml")
ap Dir.glob(json_files)
