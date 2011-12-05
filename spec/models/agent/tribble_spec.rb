require 'spec_helper'

describe Tribble do
  it { should have_db_column(:heading).of_type(:float) }

  let(:tribble) { Tribble.new }

  describe 'location' do
    describe 'x' do
      it 'defaults to nil' do
        tribble.x.should be_nil
      end
    end

    describe 'y' do
      it 'defaults to nil' do
        tribble.y.should be_nil
      end
    end
  end
end
