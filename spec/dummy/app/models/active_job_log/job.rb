module ActiveJobLog
  class Job < ApplicationRecord
    include Loggeable
  end
end
