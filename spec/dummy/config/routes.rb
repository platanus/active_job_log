Rails.application.routes.draw do
  mount ActiveJobLog::Engine => "/active_job_log"
end
