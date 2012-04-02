class MegatilePresenter
  def initialize(megatile)
    @megatile = megatile
  end
  
  def as_json
    hash = @megatile.as_api_response :megatile_with_resources
    hash.to_json
  end
end