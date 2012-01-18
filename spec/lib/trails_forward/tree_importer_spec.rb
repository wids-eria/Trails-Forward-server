# encoding: utf-8
require 'spec_helper'
require 'trails_forward/tree_importer'

describe 'TrailsForward::TreeImporter' do
  describe '.select_bin_size' do
    example 'returns appropriate bin size number' do
      TrailsForward::TreeImporter.select_bin_size(-0.1).should be_nil
      TrailsForward::TreeImporter.select_bin_size(0).should == nil
      TrailsForward::TreeImporter.select_bin_size(1.9).should == 2
      TrailsForward::TreeImporter.select_bin_size(2.0).should == 2
      TrailsForward::TreeImporter.select_bin_size(2.1).should == 4
      TrailsForward::TreeImporter.select_bin_size(3.9).should == 4
      TrailsForward::TreeImporter.select_bin_size(24.1).should == 24
      TrailsForward::TreeImporter.select_bin_size(27.9).should == 24
      TrailsForward::TreeImporter.select_bin_size(29.0).should be_nil
      TrailsForward::TreeImporter.select_bin_size(29.1).should be_nil
    end
  end
end
