require 'spec_helper'

describe Message do
  let(:sender) { create :player }
  let(:recipient) { create :player }
  let(:message) { create :message, sender: sender, recipient: recipient }
  it 'has a sender and recipient' do
    message.sender.should be_a Player
    message.recipient.should be_a Player

    message.sender.sent_messages.should == [message]
    message.recipient.received_messages.should == [message]
  end
end
