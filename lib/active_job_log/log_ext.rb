module ActiveJobLog
  module LogExt
    extend ActiveSupport::Concern

    included do
      class_attribute :disabled_log

      before_enqueue { |job| enqueue_job(job) }
      before_perform { |job| execute_job(job) }
      after_perform { |job| finish_job(job) }

      rescue_from(Exception) do |exception|
        fail_job(exception)
        raise exception
      end
    end

    class_methods do
      def disable_job_logs
        self.disabled_log = true
      end
    end

    def enqueue_job(job)
      update_job!(job.job_id, :queued, init_params(job))
    end

    def execute_job(job)
      update_job!(job.job_id, :pending, init_params(job))
    end

    def finish_job(job)
      update_job!(job.job_id, :finished)
    end

    def fail_job(exception)
      update_job!(
        job_id,
        :failed,
        error: exception.message,
        stack_trace: exception.backtrace
      )
    end

    def update_job!(job_id, status, params = {})
      return if self.class.disabled_log

      Job.update_job!(job_id, status, params)
    end

    def init_params(job)
      {
        job_class: self.class.name,
        params: job.arguments,
        executions: job.try(:executions),
        queue_name: job.queue_name
      }
    end
  end
end

ActiveJob::Base.include ActiveJobLog::LogExt
