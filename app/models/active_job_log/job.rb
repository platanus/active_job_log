module ActiveJobLog
  class Job < ApplicationRecord
    extend Enumerize

    STATUSES = %i{queued pending finished failed}

    validates :job_id, presence: true

    enumerize :status, in: STATUSES, scope: true

    serialize :params, Array
    serialize :stack_trace, Array

    before_save :set_queued_duration
    before_save :set_execution_duration
    before_save :set_total_duration

    private

    def set_queued_duration
      return if queued_at.blank? || started_at.blank?
      self.queued_duration = (started_at.to_f - queued_at.to_f).to_i
    end

    def set_execution_duration
      return if started_at.blank? || ended_at.blank?
      self.execution_duration = (ended_at.to_f - started_at.to_f).to_i
    end

    def set_total_duration
      from = queued_at || started_at
      return if from.blank? || ended_at.blank?
      self.total_duration = (ended_at.to_f - from.to_f).to_i
    end
  end
end
