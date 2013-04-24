require "spec_helper.rb"

describe RubySol::Values::AbstractMessage do
  before :each do
    @message = RubySol::Values::AbstractMessage.new
  end

  it "should generate conforming uuids" do
    @message.send(:rand_uuid).should =~ /[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}/i
  end

  it "should read externalized shortened BlazeDS messages" do
    env = create_envelope('blaze-response.bin')
    msg = env.messages[0].data
    msg.class.name.should == "RubySol::Values::AcknowledgeMessageExt"
    msg.clientId.should == "8814a067-fe0d-3a9c-a274-4aaed9bd7b0b"
    msg.body.should =~ /xmlsoap\.org/
  end
end

describe RubySol::Values::ErrorMessage do
  before :each do
    @e = Exception.new('Error message')
    @e.set_backtrace(['Backtrace 1', 'Backtrace 2'])
    @message = RubySol::Values::ErrorMessage.new(nil, @e)
  end

  it "should serialize as a hash in AMF0" do
    response = RubySol::Envelope.new
    response.messages << RubySol::Message.new('1/onStatus', '', @message)
    response.serialize.should == request_fixture('amf0-error-response.bin')
  end

  it "should extract exception properties correctly" do
    @message.faultCode.should == 'Exception'
    @message.faultString.should == 'Error message'
    @message.faultDetail.should == "Backtrace 1\nBacktrace 2"
  end
end