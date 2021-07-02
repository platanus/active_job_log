require 'rails_helper'

RSpec.describe ActiveJobLog::LogExt do
  def perform_now(job_class)
    job_class.perform_now(*job_params)
  rescue StandardError
    nil
  end

  let(:job_params) do
    %w{p1 p2}
  end

  it { expect(ActiveJobLog::Job.count).to eq(0) }

  context "with successful job" do
    let(:job_class) do
      klass = Class.new(ApplicationJob) do
        def perform(param1, param2)
          "success with #{param1} and #{param2}"
        end
      end

      stub_const('TestJob', klass)
    end

    before do
      perform_now(job_class)
      @job = ActiveJobLog::Job.last
    end

    it { expect(ActiveJobLog::Job.count).to eq(1) }
    it { expect(@job.job_id).not_to be_nil }
    it { expect(@job.params).to eq(job_params) }
    it { expect(@job.status).to eq(:finished) }
    it { expect(@job.job_class).to eq("TestJob") }
    it { expect(@job.queue_name).to eq("default") }
    it { expect(@job.error).to be_nil }
    it { expect(@job.stack_trace).to eq([]) }
    it { expect(@job.queued_at).to be_nil }
    it { expect(@job.started_at).not_to be_nil }
    it { expect(@job.ended_at).not_to be_nil }
    it { expect(@job.queued_duration).to be_nil }
    it { expect(@job.execution_duration).not_to be_nil }
    it { expect(@job.total_duration).not_to be_nil }
    it { expect(@job.executions).to eq(1) }
  end

  context "with failed job" do
    let(:job_class) do
      klass = Class.new(ApplicationJob) do
        def perform(_param1, _param2)
          raise "error"
        end
      end

      stub_const('TestJob', klass)
    end

    before do
      perform_now(job_class)
      @job = ActiveJobLog::Job.last
    end

    it { expect(ActiveJobLog::Job.count).to eq(1) }
    it { expect(@job.job_id).not_to be_nil }
    it { expect(@job.params).to eq(job_params) }
    it { expect(@job.status).to eq(:failed) }
    it { expect(@job.job_class).to eq("TestJob") }
    it { expect(@job.queue_name).to eq("default") }
    it { expect(@job.error).to eq("error") }
    it { expect(@job.stack_trace.any?).to eq(true) }
    it { expect(@job.queued_at).to be_nil }
    it { expect(@job.started_at).not_to be_nil }
    it { expect(@job.ended_at).not_to be_nil }
    it { expect(@job.queued_duration).to be_nil }
    it { expect(@job.execution_duration).not_to be_nil }
    it { expect(@job.total_duration).not_to be_nil }
    it { expect(@job.executions).to eq(1) }
  end

  context "with disabled jobs" do
    let(:disabled_job_class) do
      klass = Class.new(ApplicationJob) do
        disable_job_logs

        def perform(_param1, _param2)
          # ...
        end
      end

      stub_const('DisabledTestJob', klass)
    end

    let(:enabled_job_class) do
      klass = Class.new(ApplicationJob) do
        def perform(_param1, _param2)
          # ...
        end
      end

      stub_const('EnabledTestJob', klass)
    end

    before do
      perform_now(disabled_job_class)
      perform_now(enabled_job_class)
      @job = ActiveJobLog::Job.last
    end

    it { expect(ActiveJobLog::Job.count).to eq(1) }
    it { expect(@job.job_class).to eq('EnabledTestJob') }
  end
end
