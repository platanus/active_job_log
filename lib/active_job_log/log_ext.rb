module ActiveJobLog
  module LogExt
    extend ActiveSupport::Concern

    included do
      before_enqueue { |job| enqueue_job(job) }
      before_perform { |job| execute_job(job) }
      after_perform { |job| finish_job(job) }
      rescue_from(RuntimeError) { |exception| fail_job(exception) }

      def enqueue_job(job)
        Job.update_job!(job.job_id, :queued, job_class: self.class.name, params: job.arguments)
      end

      def execute_job(job)
        Job.update_job!(job.job_id, :pending, job_class: self.class.name, params: job.arguments)
      end

      def finish_job(job)
        Job.update_job!(job.job_id, :finished)
      end

      def fail_job(exception)
        Job.update_job!(job_id, :failed, error: exception.message, stack_trace: exception.backtrace)
      end
    end
  end
end

ActiveJob::Base.send(:include, ActiveJobLog::LogExt)
