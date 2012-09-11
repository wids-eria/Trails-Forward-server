class TimeStampLogger < Logger
  def initialize *args
    super *args
    self.formatter = nil
  end
end
