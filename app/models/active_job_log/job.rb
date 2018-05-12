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

    def self.update_job!(job_id, status, params = {})
      params.merge!(status_to_params(status))
      job = Job.find_or_create_by(job_id: job_id)
      job.update_attributes!(params)
      job
    end

    class << self
      private

      def status_to_params(status)
        time_attr = infer_duration_attr_from_status(status)
        {
          time_attr => DateTime.current,
          status: status
        }
      end

      def infer_duration_attr_from_status(status)
        case status
        when :queued
          :queued_at
        when :pending
          :started_at
        when :finished, :failed
          :ended_at
        else
          fail "invalid status"
        end
      end
    end

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
