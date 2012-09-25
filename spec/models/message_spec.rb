require 'spec_helper'

describe Message do
  let(:message) { create :message }
  it 'has a sender and recipient' do
    message.sender.should be_a Player
    message.recipient.should be_a Player

    message.sender.sent_messages.should == [message]
    message.recipient.received_messages.should == [message]
  end
end
