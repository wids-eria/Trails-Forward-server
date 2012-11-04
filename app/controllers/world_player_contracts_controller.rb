class WorldPlayerContractsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @player = Player.find(params[:player_id])
    authorize! :see_contracts, @player

    @contracts = @player.contracts

    root_key = WorldPlayerContractsController::contracts_root_key_helper @player
    template_key = WorldPlayerContractsController::contracts_template_key_helper @player

    respond_to do |format|
      format.json { render_for_api template_key, :json => @contracts, :root => root_key }
    end
  end

  def attach_megatiles
    @player = Player.find(params[:player_id])

    @contract = @player.contracts.where(:id => params[:id] || params[:contract_id]).first
    @megatiles = @player.world.megatiles.where(:id => params[:megatile_ids])

    authorize! :attach_megatiles, @contract

    allowed_to_do_this = true

    @megatiles.each do |mt|
      allowed_to_do_this &= can? :attach_to_contract, mt
      allowed_to_do_this &= mt.world == @contract.world and mt.world == @player.world
    end

    if allowed_to_do_this
      @contract.attached_megatiles << @megatiles

      root_key = WorldPlayerContractsController::contracts_root_key_helper(@player)[0..-2]
      template_key = WorldPlayerContractsController::contracts_template_key_helper @player

      respond_to do |format|
        format.json { render_for_api template_key, :json => @contract, :root => root_key }
      end
    else
      respond_to do |format|
        format.json {  render :json => "permission denied", :status => :unauthorized }
      end
    end
  end

  #helpers for this and WorldPlayerAvailableContractsController
  def self.contracts_template_key_helper(player)
    case player.type
      when 'Developer'
        :developer_contract
      when 'Conserver'
        :conserver_contract
      when 'Lumberjack'
        :lumberjack_contract
    end
  end

  def self.contracts_root_key_helper(player)
    (contracts_template_key_helper(player).to_s + "s").to_sym
  end


end