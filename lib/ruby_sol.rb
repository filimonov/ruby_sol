$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$:.unshift "#{File.expand_path(File.dirname(__FILE__))}/ruby_sol/"

require "date"
require "stringio"
require 'ruby_sol/extensions'
require 'ruby_sol/class_mapping'
require 'ruby_sol/constants'
require 'ruby_sol/pure/deserializer'
require 'ruby_sol/pure/serializer'

SOL_HEADER = "\0\xBF"
SOL_SIGNATURE = "TCSO\0\x04\0\0\0\0"
SOL_PADDING = "\0"

module RubySol

  Deserializer = RubySol::Pure::Deserializer
  Serializer = RubySol::Pure::Serializer

  # usage RubySol::read_sol(File.new(filename, 'r:ASCII-8BIT').read)
  def self.read_sol(source)

    if StringIO === source
      f = source
    elsif source
      f = StringIO.new(source)
    elsif f.nil?
      raise AMFError, "no source to deserialize"
    end

    header = f.read(2)
    len=f.read(4).unpack('N').first
    throw SOLError, 'bad size' unless (len + 6 == f.size)
    signature = f.read(10)
    throw SOLError, 'bad signature' unless (signature == SOL_SIGNATURE)

    des = RubySol::Deserializer.new(RubySol::ClassMapper.new)
    des.source = f
    sol_name=des.amf0_read_string()

    zeros=f.read(3)
    throw SOLError, 'bad signature' unless (zeros == SOL_PADDING * 3)

    amf_version = f.read(1).unpack('C').first
    values = {'__ruby_sol__amf_version' => amf_version,
              '__ruby_sol__sol_name' => sol_name }

    des.source = f

    while !f.eof?
      str = amf_version == 3? des.amf3_read_string() : des.amf0_read_string();
      obj = amf_version == 3? des.amf3_deserialize() : des.amf0_deserialize();
      values[str] = obj
      padding = f.read(1);
    end
    return values
  end

  def self.create_sol(content)
    name = content['__ruby_sol__sol_name'] || 'unknown'
    version = content['__ruby_sol__amf_version'] || 0

    ser = RubySol::Serializer.new(RubySol::ClassMapper.new)

    ser.stream << SOL_SIGNATURE
    ser.amf0_write_string_wo_marker(name)
    ser.stream << SOL_PADDING * 3
    ser.stream << [version].pack('c')

    content.each_key { |key|
      if key !~ /^__ruby_sol__/
        if version == 0
          ser.amf0_write_string_wo_marker(key)
          ser.amf0_serialize(content[key])
          ser.stream << SOL_PADDING
        elsif version == 3
          ser.amf3_write_utf8_vr(key)
          ser.amf3_serialize(content[key])
          ser.stream << SOL_PADDING
        end
      end
    }
    res = ser.stream
    return SOL_HEADER.force_encoding("ASCII-8BIT") + [res.bytesize].pack('N').force_encoding("ASCII-8BIT") + res.force_encoding("ASCII-8BIT")
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

  # to have RocketAMF specs compatibility
  def self.deserialize source, amf_version = 0
    des = RubySol::Deserializer.new(RubySol::ClassMapper.new)
    des.deserialize(amf_version, source)
  end
  def self.serialize obj, amf_version = 0
    ser = RubySol::Serializer.new(RubySol::ClassMapper.new)
    ser.serialize(amf_version, obj)
  end

  # The base exception for AMF errors.
  class AMFError < StandardError; end

  # The base exception for ruby SOL errors.
  class SOLError < StandardError; end
end