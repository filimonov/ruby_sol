$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$:.unshift "#{File.expand_path(File.dirname(__FILE__))}/ruby_sol/"

require "date"
require "stringio"
require 'ruby_sol/extensions'
require 'ruby_sol/class_mapping'
require 'ruby_sol/constants'
require 'ruby_sol/remoting'

module RubySol
  require 'ruby_sol/pure'

  # Deserialize the AMF string _source_ of the given AMF version into a Ruby
  # data structure and return it. Creates an instance of <tt>RubySol::Deserializer</tt>
  # with a new instance of <tt>RubySol::ClassMapper</tt> and calls deserialize
  # on it with the given source and amf version, returning the result.
  def self.deserialize source, amf_version = 0
    des = RubySol::Deserializer.new(RubySol::ClassMapper.new)
    des.deserialize(amf_version, source)
  end

  # Serialize the given Ruby data structure _obj_ into an AMF stream using the
  # given AMF version. Creates an instance of <tt>RubySol::Serializer</tt>
  # with a new instance of <tt>RubySol::ClassMapper</tt> and calls serialize
  # on it with the given object and amf version, returning the result.
  def self.serialize obj, amf_version = 0
    ser = RubySol::Serializer.new(RubySol::ClassMapper.new)
    ser.serialize(amf_version, obj)
  end

  # We use const_missing to define the active ClassMapper at runtime. This way,
  # heavy modification of class mapping functionality is still possible without
  # forcing extenders to redefine the constant.
  def self.const_missing const #:nodoc:
    if const == :ClassMapper
      RubySol.const_set(:ClassMapper, RubySol::ClassMapping)
    else
      super(const)
    end
  end

  # The base exception for AMF errors.
  class AMFError < StandardError; end
end