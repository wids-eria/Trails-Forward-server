class ContractsController < ApplicationController
  skip_authorization_check
  expose(:world)
  expose(:contracts) { world.contracts }
  expose(:contract)

  respond_to :json, :html


  def index
    respond_with contracts
  end


  def show
    respond_with contract
  end


  def create
    contract.save
    ContractsController::stuff_megatiles_into_contract contract, params[:megatile_ids_to_include]
    respond_with contract, notice: 'Contract Created', location: world_contracts_path
  end


  def update
    contract.update_attributes params[:contract]
    ContractsController::stuff_megatiles_into_contract contract, params[:megatile_ids_to_include]
    respond_with contract, notice: 'Contract Updated', location: world_contracts_path
  end

  def self.stuff_megatiles_into_contract(contract, megatile_ids_string)
    return if megatile_ids_string == nil
    ids = megatile_ids_string.split(",").map { |s| s.to_i}
    return if ids.length == 0
    megatiles = contract.world.megatiles.where :id => ids
    megatiles.each do |mt|
      contract.included_megatiles << mt if mt.owner == nil
    end
  end
end
