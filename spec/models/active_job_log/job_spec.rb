require 'rails_helper'

module ActiveJobLog
  RSpec.describe Job, type: :model do
    it "has a valid factory" do
      expect(create(:active_job_log_job)).to be_valid
    end

    describe "Validations" do
      it { is_expected.to enumerize(:status).in(:queued, :pending, :finished, :failed) }
    end

    describe "#params" do
      let(:job) { create(:active_job_log_job) }
      let(:params) { [1, 2] }

      it { expect(job.params).to eq([]) }
      it { expect { job.params = params }.to change(job, :params).from([]).to(params) }
    end

    describe "#stack_trace" do
      let(:job) { create(:active_job_log_job) }
      let(:stack) { [1, 2] }

      it { expect(job.stack_trace).to eq([]) }
      it { expect { job.stack_trace = stack }.to change(job, :stack_trace).from([]).to(stack) }
    end

    describe "#set_queued_duration" do
      let(:job) { build(:active_job_log_job, queued_at: queued_at, started_at: started_at) }

      context "with defined started_at and queued_at" do
        let(:queued_at) { started_at - 2.days }
        let(:started_at) { DateTime.current }

        it { expect { job.save! }.to change(job, :queued_duration).from(nil).to(172800) }
      end

      context "with nil started_at" do
        let(:queued_at) { DateTime.current }
        let(:started_at) { nil }

        it { expect { job.save! }.not_to change(job, :queued_duration) }
      end

      context "with nil queued_at" do
        let(:queued_at) { nil }
        let(:started_at) { DateTime.current }

        it { expect { job.save! }.not_to change(job, :queued_duration) }
      end
    end

    describe "#set_execution_duration" do
      let(:job) { build(:active_job_log_job, started_at: started_at, ended_at: ended_at) }

      context "with defined ended_at and started_at" do
        let(:started_at) { ended_at - 2.days }
        let(:ended_at) { DateTime.current }

        it { expect { job.save! }.to change(job, :execution_duration).from(nil).to(172800) }
      end

      context "with nil ended_at" do
        let(:started_at) { DateTime.current }
        let(:ended_at) { nil }

        it { expect { job.save! }.not_to change(job, :execution_duration) }
      end

      context "with nil started_at" do
        let(:started_at) { nil }
        let(:ended_at) { DateTime.current }

        it { expect { job.save! }.not_to change(job, :execution_duration) }
      end
    end

    describe "#set_total_duration" do
      let(:job) do
        build(:active_job_log_job, queued_at: queued_at, started_at: started_at, ended_at: ended_at)
      end

      let(:queued_at) { ended_at - 3.days }
      let(:started_at) { ended_at - 2.days }
      let(:ended_at) { DateTime.current }

      it { expect { job.save! }.to change(job, :total_duration).from(nil).to(259200) }

      context "with undefined queued_at" do
        let(:queued_at) { nil }

        it { expect { job.save! }.to change(job, :total_duration).from(nil).to(172800) }
      end

      context "with undefined started_at" do
        let(:started_at) { nil }

        it { expect { job.save! }.to change(job, :total_duration).from(nil).to(259200) }
      end

      context "with undefined ended_at" do
        let(:queued_at) { DateTime.current - 3.days }
        let(:started_at) { DateTime.current - 2.days }
        let(:ended_at) { nil }

        it { expect { job.save! }.not_to change(job, :total_duration) }
      end

      context "with undefined queued_at and started_at" do
        let(:queued_at) { nil }
        let(:started_at) { nil }
        let(:ended_at) { DateTime.current }

        it { expect { job.save! }.not_to change(job, :total_duration) }
      end
    end

    describe "#update_job!" do
      let(:job_id) { "x" }
      let(:status) { :queued }
      let(:perform) { described_class.update_job!(job_id, status, params) }

      let(:params) do
        {
          params: [1],
          stack_trace: [2],
          error: "error",
          job_class: "MyJob"
        }
      end

      it { expect { perform }.to change(ActiveJobLog::Job, :count).from(0).to(1) }

      context "with existent job" do
        let!(:job) { create(:active_job_log_job, job_id: job_id) }

        it { expect { perform }.not_to change(ActiveJobLog::Job, :count) }
      end

      context "with queued status" do
        before { @job = perform }

        it { expect(@job.job_id).to eq(job_id) }
        it { expect(@job.error).to eq("error") }
        it { expect(@job.params).to eq([1]) }
        it { expect(@job.stack_trace).to eq([2]) }
        it { expect(@job.job_class).to eq("MyJob") }
        it { expect(@job.status).to eq(:queued) }
        it { expect(@job.queued_at).not_to be_nil }
        it { expect(@job.started_at).to be_nil }
        it { expect(@job.ended_at).to be_nil }
      end

      context "with pending status" do
        let(:status) { :pending }

        before { @job = perform }

        it { expect(@job.status).to eq(:pending) }
        it { expect(@job.queued_at).to be_nil }
        it { expect(@job.started_at).not_to be_nil }
        it { expect(@job.ended_at).to be_nil }
      end

      context "with finished status" do
        let(:status) { :finished }

        before { @job = perform }

        it { expect(@job.status).to eq(:finished) }
        it { expect(@job.queued_at).to be_nil }
        it { expect(@job.started_at).to be_nil }
        it { expect(@job.ended_at).not_to be_nil }
      end

      context "with failed status" do
        let(:status) { :failed }

        before { @job = perform }

        it { expect(@job.status).to eq(:failed) }
        it { expect(@job.queued_at).to be_nil }
        it { expect(@job.started_at).to be_nil }
        it { expect(@job.ended_at).not_to be_nil }
      end
    end
  end
end
