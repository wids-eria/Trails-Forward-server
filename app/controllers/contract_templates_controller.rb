class ContractTemplatesController < ApplicationController
  skip_authorization_check
  expose(:contract_templates)
  expose(:contract_template)

  respond_to :json, :html


  def index
    @contract_templates = ContractTemplate.all # not sure why decent exposure isn't making this work
    respond_with @contract_templates
  end


  def show
    respond_with contract_template
  end


  def create
    if contract_template.save
      flash[:notice] = "Template Created"
      respond_with contract_template, notice: 'Created!', location: contract_templates_path
    else
      render :new
    end
  end


  def update
    flash[:notice] = "Template Updated" if contract_template.update_attributes params[:contract_template]

    respond_with contract_template, location: contract_templates_path
  end

end
