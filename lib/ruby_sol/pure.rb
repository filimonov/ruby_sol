require 'ruby_sol/pure/deserializer'
require 'ruby_sol/pure/serializer'
require 'ruby_sol/pure/remoting'

module RubySol
  # This module holds all the modules/classes that implement AMF's functionality
  # in pure ruby
  module Pure
    $DEBUG and warn "Using pure library for RubySol."
  end

  #:stopdoc:
  # Import serializer/deserializer
  Deserializer = RubySol::Pure::Deserializer
  Serializer = RubySol::Pure::Serializer

  # Modify envelope so it can serialize/deserialize
  class Envelope
    remove_method :populate_from_stream
    remove_method :serialize
    include RubySol::Pure::Envelope
  end
  #:startdoc:
end