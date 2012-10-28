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
    if contract.save
      flash[:notice] = "Contract Created"
      respond_with contract, notice: 'Created!', location: world_contract_path
    else
      render :new
    end
  end


  def update
    flash[:notice] = "Contract Updated" if contract.update_attributes params[:contract]

    respond_with contract, location: world_contracts_path
  end
end
