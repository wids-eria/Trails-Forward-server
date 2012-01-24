# encoding: utf-8
require 'spec_helper'
require 'trails_forward/tree_importer'

describe 'TrailsForward::TreeImporter' do
  describe '.populate_with_uneven_aged_distribution' do
    example 'should definitely populate the bins closest to the mean' do
      tile_hash = { tree_size: 12 }
      target_basal_area = 200
      TrailsForward::TreeImporter.populate_with_uneven_aged_distribution tile_hash, target_basal_area
      tile_hash[:num_2_inch_diameter_trees].should > 0
      tile_hash[:num_4_inch_diameter_trees].should > 0
    end
  end

  describe '.populate_with_even_aged_distribution' do
    example 'should definitely populate the bins closest to the mean' do
      tile_hash = { tree_size: 12 }
      target_basal_area = 200
      TrailsForward::TreeImporter.populate_with_even_aged_distribution tile_hash, target_basal_area
      tile_hash[:num_12_inch_diameter_trees].should > 0
      tile_hash[:num_14_inch_diameter_trees].should > 0
    end
  end

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
