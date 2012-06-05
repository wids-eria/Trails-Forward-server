require 'spec_helper'

describe MaleMarten do
 let!(:world) {create :world_with_tiles}
 let!(:male_marten) {create :male_marten, :world => world, :location => [1,1], :previous_location => world.resource_tile_at(1,2), :age => 0} 
 before do
   world.resource_tiles.each do |tile|
     tile.update_attributes(:population => {:vole_population => 0})
   end
   world.resource_tile_at(0,0).update_attributes(:landcover_class_code => 43, :population => {:vole_population => 1})
   world.resource_tile_at(0,1).update_attributes(:landcover_class_code => 43, :population => {:vole_population => 1})
   world.resource_tile_at(1,1).update_attributes(:landcover_class_code => 43, :population => {:vole_population => 1})
   world.resource_tile_at(1,0).update_attributes(:landcover_class_code => 43, :population => {:vole_population => 1})
 end

 it 'turns' do
   male_marten.heading = 0
   male_marten.turn(360)
   male_marten.turn(360)
   male_marten.turn(360)
   male_marten.turn(360)
   male_marten.heading.should == 0
   male_marten.heading = 7
   male_marten.turn(360)
   male_marten.turn(360)
   male_marten.turn(360)
   male_marten.turn(360)
   male_marten.heading.should == 7
 end

 it 'faces' do
   male_marten.face(world.resource_tile_at(0,0)).should == 315
   male_marten.face(world.resource_tile_at(1,0)).should == 45
   male_marten.face(world.resource_tile_at(1,1)).should == 135
   male_marten.face(world.resource_tile_at(0,1)).should == 225
 end
 it 'ticks' do
   male_marten.energy = 420
   male_marten.tick
 end
end

describe FemaleMarten do
 let!(:world) {create :world_with_tiles}
 let!(:female_marten) {create :female_marten, :age => 0, :world => world, :location => [1,1], :previous_location => world.resource_tile_at(1,2)}
 before do
   world.resource_tiles.each do |tile|
     tile.update_attributes(:population => {:vole_population => 0})
   end
   world.resource_tile_at(0,0).update_attributes(:landcover_class_code => 43, :population => {:vole_population => 1})
   world.resource_tile_at(0,1).update_attributes(:landcover_class_code => 43, :population => {:vole_population => 1})
   world.resource_tile_at(1,1).update_attributes(:landcover_class_code => 43, :population => {:vole_population => 1})
   world.resource_tile_at(1,0).update_attributes(:landcover_class_code => 43, :population => {:vole_population => 1})
 end


 it 'ticks' do
   female_marten.energy = 109
   female_marten.tick
 end
end


