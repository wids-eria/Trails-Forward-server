require 'spec_helper'

describe ContractTemplate do
  let(:lumberjack_contract_template) { build :contract_template_lumberjack }
  let(:developer_contract_template) { build :contract_template_developer }

  it 'can save a minimal lumberjack template' do
    lumberjack_contract_template.save.should be_true
  end

  it 'cannot save a malformed lumberjack template' do
    lumberjack_contract_template.wood_type = "bullshit"
    lumberjack_contract_template.volume_required = nil
    lumberjack_contract_template.save.should be_false
  end

  it 'can save a minimal developer template' do
    developer_contract_template.save.should be_true
  end

  it 'cannot save a malformed developer template' do
    developer_contract_template.wood_type = "saw timber"
    developer_contract_template.volume_required = 22
    developer_contract_template.save.should be_false
  end

end
