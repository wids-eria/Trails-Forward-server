require 'spec_helper'

describe Contract do
  let(:lumberjack_contract) { build :contract_lumberjack }

  it 'can save an UNOWNED lumberjack contract with sane values' do
    lumberjack_contract.save.should be_true
  end

end
