class ActiveJobLog::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def create_initializer
    template "initializer.rb", "config/initializers/active_job_log.rb"
  end

  def mount_routes
    line = "Rails.application.routes.draw do\n"
    inject_into_file "config/routes.rb", after: line do <<-"HERE".gsub(/^ {4}/, '')
      mount ActiveJobLog::Engine => "/active_job_log"
    HERE
    end
  end

  def copy_job_model
    copy_file "job_model.rb", "app/models/active_job_log/job.rb"
  end

  def copy_engine_migrations
    rake "railties:install:migrations"
  end
end
