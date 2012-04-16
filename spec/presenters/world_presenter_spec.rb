require 'spec_helper'

describe WorldPresenter do
  let(:world) { create :world_with_properties }

  describe "#save_png" do
    let(:path)      { "tmp/worlds/#{world.id}/images" }
    let(:filename)  { "world.png" }
    let(:full_path) { File.join(path, filename) }

    before do
      presenter = WorldPresenter.new(world)
      presenter.stubs(path_to: path)
      presenter.save_png
    end

    it 'saves the map to disk' do
      File.exists?(full_path).should == true
    end

    after do
      FileUtils.rm_rf "tmp/worlds"
    end
  end

end
