module Todoable
  class ApiError < StandardError
    def initialize(msg)
      super("API Error Observed: #{msg}")
    end
  end

  class ArgError < StandardError
  end
end
