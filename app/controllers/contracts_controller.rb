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

    respond_with contract, notice: 'Contract Created', location: world_contracts_path
  end


  def update
    contract.update_attributes params[:contract]

    respond_with contract, notice: 'Contract Updated', location: world_contracts_path
  end
end
