require "spec_helper.rb"

describe RubySol::ClassMapping do
  before :each do
    RubySol::ClassMapping.reset
    RubySol::ClassMapping.define do |m|
      m.map :as => 'ASClass', :ruby => 'ClassMappingTest'
    end
    @mapper = RubySol::ClassMapping.new
  end

  describe "class name mapping" do
    it "should allow resetting of mappings back to defaults" do
      @mapper.get_as_class_name('ClassMappingTest').should_not be_nil
      RubySol::ClassMapping.reset
      @mapper = RubySol::ClassMapping.new
      @mapper.get_as_class_name('ClassMappingTest').should be_nil
      @mapper.get_as_class_name('RubySol::Values::AcknowledgeMessage').should_not be_nil
    end

    it "should return AS class name for ruby objects" do
      @mapper.get_as_class_name(ClassMappingTest.new).should == 'ASClass'
      @mapper.get_as_class_name('ClassMappingTest').should == 'ASClass'
      @mapper.get_as_class_name(RubySol::Values::TypedHash.new('ClassMappingTest')).should == 'ASClass'
      @mapper.get_as_class_name('BadClass').should be_nil
    end

    it "should instantiate a ruby class" do
      @mapper.get_ruby_obj('ASClass').should be_a(ClassMappingTest)
    end

    it "should properly instantiate namespaced classes" do
      RubySol::ClassMapping.mappings.map :as => 'ASClass', :ruby => 'ANamespace::TestRubyClass'
      @mapper = RubySol::ClassMapping.new
      @mapper.get_ruby_obj('ASClass').should be_a(ANamespace::TestRubyClass)
    end

    it "should return a hash with original type if not mapped" do
      obj = @mapper.get_ruby_obj('UnmappedClass')
      obj.should be_a(RubySol::Values::TypedHash)
      obj.type.should == 'UnmappedClass'
    end

    it "should map special classes from AS by default" do
      as_classes = [
        'flex.messaging.messages.AcknowledgeMessage',
        'flex.messaging.messages.CommandMessage',
        'flex.messaging.messages.RemotingMessage'
      ]

      as_classes.each do |as_class|
        @mapper.get_ruby_obj(as_class).should_not be_a(RubySol::Values::TypedHash)
      end
    end

    it "should map special classes from ruby by default" do
      ruby_classes = [
        'RubySol::Values::AcknowledgeMessage',
        'RubySol::Values::ErrorMessage'
      ]

      ruby_classes.each do |obj|
        @mapper.get_as_class_name(obj).should_not be_nil
      end
    end

    it "should allow config modification" do
      RubySol::ClassMapping.mappings.map :as => 'SecondClass', :ruby => 'ClassMappingTest'
      @mapper = RubySol::ClassMapping.new
      @mapper.get_as_class_name(ClassMappingTest.new).should == 'SecondClass'
    end
  end

  describe "ruby object populator" do
    it "should populate a ruby class" do
      obj = @mapper.populate_ruby_obj ClassMappingTest.new, {:prop_a => 'Data'}
      obj.prop_a.should == 'Data'
    end

    it "should populate a typed hash" do
      obj = @mapper.populate_ruby_obj RubySol::Values::TypedHash.new('UnmappedClass'), {:prop_a => 'Data'}
      obj[:prop_a].should == 'Data'
    end
  end

  describe "property extractor" do
    it "should extract hash properties" do
      hash = {:a => 'test1', 'b' => 'test2'}
      props = @mapper.props_for_serialization(hash)
      props.should == {'a' => 'test1', 'b' => 'test2'}
    end

    it "should extract object properties" do
      obj = ClassMappingTest.new
      obj.prop_a = 'Test A'

      hash = @mapper.props_for_serialization obj
      hash.should == {'prop_a' => 'Test A', 'prop_b' => nil}
    end

    it "should extract inherited object properties" do
      obj = ClassMappingTest2.new
      obj.prop_a = 'Test A'
      obj.prop_c = 'Test C'

      hash = @mapper.props_for_serialization obj
      hash.should == {'prop_a' => 'Test A', 'prop_b' => nil, 'prop_c' => 'Test C'}
    end
  end
end