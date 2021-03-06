class CreateActiveJobLogJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :active_job_log_jobs do |t|
      t.string :job_id, index: true
      t.text :params
      t.string :status
      t.string :job_class
      t.text :error
      t.text :stack_trace
      t.datetime :queued_at
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :queued_duration
      t.integer :execution_duration
      t.integer :total_duration
      t.integer :executions
      t.string :queue_name

      t.timestamps
    end
  end
end
