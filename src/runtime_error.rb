class RuntimeError < StandardError
  attr_reader :message

  def initialize(token, message)
    super(token)
    @message = message
  end
end
