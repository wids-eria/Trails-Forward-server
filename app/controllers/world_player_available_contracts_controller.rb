class WorldPlayerAvailableContractsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @player = Player.find(params[:player_id])
    authorize! :see_contracts, @player

    @contracts = @player.available_contracts

    root_key = WorldPlayerContractsController::contracts_root_key_helper @player
    template_key = WorldPlayerContractsController::contracts_template_key_helper @player

    respond_to do |format|
      format.json { render_for_api template_key, :json => @contracts, :root => root_key }
    end
  end

  def accept
    @player = Player.find(params[:player_id])
    @contract = Contract.find(params[:id] || params[:available_contract_id])

    authorize! :accept_contract, @contract

    @contract.player = @player

    ActiveRecord::Base.transaction do
      great_success = true   # yakshemash
      @contract.included_megatiles.each do |mt|
        if mt.owner == nil
          mt.owner = @player
          great_success &= mt.save
        else
          great_success = false
        end
      end
      great_success &= @contract.save

      unless great_success
        raise ActiveRecord::Rollback
      end
    end

    if great_success
      root_key = WorldPlayerContractsController::contracts_root_key_helper(@player)[0..-2]
      template_key = WorldPlayerContractsController::contracts_template_key_helper @player

      respond_to do |format|
        format.json { render_for_api template_key, :json => @contract, :root => root_key }
      end
    else
      respond_to do |format|
        format.json  { render :json => @contract.errors, :status => :unprocessable_entity }
      end
    end
  end #accept

end