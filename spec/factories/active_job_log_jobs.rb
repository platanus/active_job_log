FactoryBot.define do
  factory :active_job_log_job, class: 'ActiveJobLog::Job' do
    job_id "MyString"
    status :pending
    job_class "MyJob"
  end
end
