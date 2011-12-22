# encoding: utf-8
require 'spec_helper'
require 'trails_forward/core_extensions/vector'

class Vector
  include TrailsForward::CoreExtensions::Vector
end

describe Vector do
  let(:vector) { Vector[*tuple] }

  describe ".sum" do
    it 'returns a vector that is the sum of the passed in vectors' do
      Vector.sum([Vector[1,1], Vector[2,5], Vector[-4,7]]).should == Vector[-1,13]
    end
  end

  describe ".from_radians" do
    let(:radians) { Math::PI / 2 }
    subject { Vector.from_radians(radians).clean }
    it { should == Vector[0,1] }
  end

  describe ".from_degrees" do
    let(:degrees) { 90 }
    subject { Vector.from_degrees(degrees).clean }
    it { should == Vector[0,1] }
  end

  describe ".from_heading" do
    let(:heading) { 90 }
    subject { Vector.from_heading(heading).clean }
    it { should == Vector[1,0] }
  end

  describe "#normalize" do
    subject { vector.normalize }

    context "a 0'd vector" do
      let(:tuple) { [0, 0] }
      it { should == Vector[0,0] }
    end

    context "a normalized vector" do
      let(:tuple) { [1,0] }
      it { should == Vector[1,0] }
    end

    context "a short vector" do
      let(:tuple) { [0,0.5] }
      it { should == Vector[0,1] }
    end

    context "a long vector" do
      let(:tuple) { [2,0] }
      it { should == Vector[1,0] }
    end

    context "a compund vector in quadrant 1" do
      let(:tuple) { [1,1] }
      it { should == Vector[1/Math.sqrt(2), 1/Math.sqrt(2)] }
    end

    context "a compund vector in quadrant 2" do
      let(:tuple) { [-1,1] }
      it { should == Vector[-1/Math.sqrt(2), 1/Math.sqrt(2)] }
    end

    context "a compund vector in quadrant 3" do
      let(:tuple) { [-1,-1] }
      it { should == Vector[-1/Math.sqrt(2), -1/Math.sqrt(2)] }
    end

    context "a compund vector in quadrant 4" do
      let(:tuple) { [1,-1] }
      it { should == Vector[1/Math.sqrt(2), -1/Math.sqrt(2)] }
    end
  end

  describe "#square_r" do
    subject { vector.square_r }

    context "a 0'd vector" do
      let(:tuple) { [0, 0] }
      it { should == 0 }
    end

    context "a normalized vector" do
      let(:tuple) { [1,0] }
      it { should == 1 }
    end

    context "a short vector" do
      let(:tuple) { [0,0.5] }
      it { should == 1 }
    end

    context "a long vector" do
      let(:tuple) { [2,0] }
      it { should == 1 }
    end

    context "a compund vector in quadrant 1" do
      let(:tuple) { [1,1] }
      it { should == Math.sqrt(2) }
    end

    context "a compund vector in quadrant 2" do
      let(:tuple) { [-1,1] }
      it { should == Math.sqrt(2) }
    end

    context "a compund vector in quadrant 3" do
      let(:tuple) { [-1,-1] }
      it { should == Math.sqrt(2) }
    end

    context "a compund vector in quadrant 4" do
      let(:tuple) { [1,-1] }
      it { should == Math.sqrt(2) }
    end
  end

  describe "#square_in_r?" do
    subject { vector.square_in_r? radius }

    context "radius 0" do
      let(:radius) { 0 }

      context "at center" do
        let(:tuple) { [0,0] }
        it { should be }
      end

      context "near center" do
        let(:tuple) { [0.1,-0.1] }
        it { should be }
      end

      context "near corner" do
        let(:tuple) { [-0.9,0.9] }
        it { should be }
      end

      context "left" do
        let(:tuple) { [-1,0] }
        it { should be }
      end

      context "bottom" do
        let(:tuple) { [0,-1] }
        it { should be }
      end

      context "right" do
        let(:tuple) { [1,0] }
        it { should_not be }
      end

      context "top" do
        let(:tuple) { [0,1] }
        it { should_not be }
      end

      context "left bottom" do
        let(:tuple) { [-1,-1] }
        it { should be }
      end

      context "right bottom" do
        let(:tuple) { [1,-1] }
        it { should_not be }
      end

      context "left top" do
        let(:tuple) { [-1,1] }
        it { should_not be }
      end

      context "right top" do
        let(:tuple) { [1,1] }
        it { should_not be }
      end

      context "outside left" do
        let(:tuple) { [-1.1, 0] }
        it { should_not be }
      end

      context "outside right" do
        let(:tuple) { [1.1, 0] }
        it { should_not be }
      end

      context "outside top" do
        let(:tuple) { [0, 1.1] }
        it { should_not be }
      end

      context "outside bottom" do
        let(:tuple) { [-1.1, 0] }
        it { should_not be }
      end

      context "outside left bottom" do
        let(:tuple) { [-1.1, -1.1] }
        it { should_not be }
      end

      context "outside left top" do
        let(:tuple) { [-1.1, 1.1] }
        it { should_not be }
      end

      context "outside right bottom" do
        let(:tuple) { [1.1, -1.1] }
        it { should_not be }
      end

      context "outside right top" do
        let(:tuple) { [1.1, 1.1] }
        it { should_not be }
      end
    end
  end

  describe '#to_radians' do
    let(:tuple) { [0,1] }
    subject { vector.to_radians }
    it { should == Math::PI / 2 }
  end

  describe '#to_degrees' do
    let(:tuple) { [0,1] }
    subject { vector.to_degrees }
    it { should == 90 }
  end

  describe '#to_heading' do
    let(:tuple) { [-1,-1] }
    subject { vector.to_heading }
    it { should == 225 }
  end

  describe '#radians_to' do
    let(:v1) { Vector[1,1] }
    let(:v2) { Vector[-1,0] }
    let(:v3) { Vector[0,-1] }

    context 'returns radians between vectors' do
      example '[1,1] to [-1,0] = 3π/4' do
        v1.radians_to(v2).should == 3 * Math::PI / 4
      end

      example '[-1,0] to [0,-1] = π/2' do
        v2.radians_to(v3).should == Math::PI / 2
      end

      example '[0,-1] to [1,1] = 3π/4' do
        v3.radians_to(v1).should == 3 * Math::PI / 4
      end

      example '[-1,0] to [1,1] = -3π/4' do
        v2.radians_to(v1).should == -3 * Math::PI / 4
      end

      example '[0,-1] to [-1,0] = -π/2' do
        v3.radians_to(v2).should == -Math::PI / 2
      end

      example '[1,1] to [0,-1] = -3π/4' do
        v1.radians_to(v3).should == -3 * Math::PI / 4
      end
    end

  end

end
