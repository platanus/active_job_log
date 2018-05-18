FactoryBot.define do
  factory :active_job_log_job, class: 'ActiveJobLog::Job' do
    sequence(:job_id) { |n| "job##{n}" }
    status :pending
    job_class "MyJob"
  end
end
