require 'spec_helper'

describe Tribble do
  it { should have_db_column(:heading).of_type(:float) }

  let(:tribble) { build(:tribble) }

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

  describe '#location=' do
    it 'assigns coords to x and y' do
      tribble.location = [4.4, 5.5]
      tribble.x.should == 4.4
      tribble.y.should == 5.5
    end
  end

  describe '#location' do
    it 'returns array of [x,y] values' do
      tribble = build(:tribble, x: 1.5, y:3.7)
      tribble.location.should == [1.5, 3.7]
    end
  end

  describe '#move' do
    let(:tribble) { build(:tribble, location: location, heading: heading) }
    subject do
      tribble.move(distance)
      tribble
    end

    context 'starting at location [0, 0]' do
      let(:location) { [0, 0] }

      context 'with heading 0' do
        let(:heading) { 0 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [0, 1] }
        end

        context 'passed a distance of -1' do
          let(:distance) { -1 }
          its(:location) { should == [0, -1] }
        end
      end

      context 'with heading 90' do
        let(:heading) { 90 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [1, 0] }
        end

        context 'passed a distance of -1' do
          let(:distance) { -1 }
          its(:location) { should == [-1, 0] }
        end
      end

    end

    context 'starting at location [0, 3.7]' do
      let(:location) { [0, 3.7] }

      context 'with heading 0' do
        let(:heading) { 0 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [0, 4.7] }
        end

        context 'passed a distance of -1' do
          let(:distance) { -1 }
          its(:location) { should == [0, 2.7] }
        end
      end

    end

  end
end
