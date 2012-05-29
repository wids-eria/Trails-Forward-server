require 'spec_helper'

describe MaleMarten do
 let(:male_marten) {create :male_marten} 
 it 'ticks' do
   male_marten.tick
 end
end

describe FemaleMarten do
 let(:female_marten) {create :female_marten} 
 it 'ticks' do
   female_marten.tick
 end
end


