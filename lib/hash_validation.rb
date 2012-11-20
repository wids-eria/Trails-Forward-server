module HashValidation
  extend ActiveSupport::Concern

  def required_keys!(*keys)
    self.assert_valid_keys(*keys)
    raise ArgumentError.new("Missing options #{required_keys - options.keys}") if self.keys != keys
  end
end
