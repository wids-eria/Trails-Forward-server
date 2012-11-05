require 'spec_helper'

describe LoggingEquipmentTemplatesController do
  include Devise::TestHelpers
  render_views

  let!(:logged_in_player) { create :player }
  let(:shared_params) { {} }

  before do
    sign_in logged_in_player.user
  end

  describe "GET #index" do
    it "assigns all messages as @messages" do
      get :index, shared_params
      response.should be_successful
    end
  end
end
