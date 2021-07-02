# Active Job Log

[![Gem Version](https://badge.fury.io/rb/active_job_log.svg)](https://badge.fury.io/rb/active_job_log)
[![CircleCI](https://circleci.com/gh/platanus/active_job_log.svg?style=shield)](https://app.circleci.com/pipelines/github/platanus/active_job_log)
[![Coverage Status](https://coveralls.io/repos/github/platanus/active_job_log/badge.svg?branch=master)](https://coveralls.io/github/platanus/active_job_log?branch=master)

Rails engine to register jobs history, adding: job state, error feedback, duration, etc.

## Installation

Add to your Gemfile:

```ruby
gem "active_job_log"
```

```bash
bundle install
```

Then, run the installer:

```bash
rails generate active_job_log:install
```

## Usage

Suppose you have defined the following job:

```ruby
class MyJob < ActiveJob::Base
  def perform(param1, param2)
    # ...
  end
end
```

Installing this gem, after executing the job, if you execute like this:

```ruby
MyJob.perform_later("p1", "p2")
```

you will get:

```ruby
job = ActiveJobLog::Job.last
job.job_id #=> "0ca5075e-c601-45a1-9bbe-147b4d3d5391"
job.params #=> ["p1", "p2"]
job.status #=> "finished"
job.job_class #=> "MyJob"
job.error #=> nil
job.stack_trace #=> nil
job.queued_at #=> Sat, 12 May 2018 20:25:00 UTC +00:00
job.started_at #=> Sat, 12 May 2018 20:30:00 UTC +00:00
job.ended_at #=> Sat, 12 May 2018 20:30:00 UTC +00:00
job.queued_duration #=> 5
job.execution_duration #=> 10
job.total_duration #=> 15
job.queue_name #=> "default"
job.executions #=> 0
```

### Attributes

- `job_id`: ActiveJob's job_id.

- `params`: parameters used to call your job.

queued pending finished failed

- `status`:
  - `queued`: the job is queued but not executed yet.
  - `pending`: the job is being executed.
  - `finished`: the job ended satisfactorily.
  - `failed`: the job ended with errors.


- `job_class`: a string containing your job class name.

- `error`: the exception message if your job ends with errors.

- `stack_trace`: the exception backtrace if your job ends with errors.

- `queued_at`: datetime when job was queued.

- `started_at`: datetime when job was executed.

- `ended_at`: datetime when job finished regardless of whether it ended or not with errors.

- `queued_duration`: seconds that lasted in queue (not registered if it is executed with `perform_now`).

- `execution_duration`: seconds that the execution lasted.

- `total_duration`: queued_duration + execution_duration.

- `queue_name`: job's queue name.

- `executions`: number of times this job has been executed (which increments on every retry, like after an exception.

### Disable logging

If you want to avoid logging a specific job you have to add `disable_job_logs` config option on that job. For example:

```ruby
class MyJob < ActiveJob::Base
  disable_job_logs

  def perform(param1, param2)
    # ...
  end
end
```

### Important

If your job calls the `rescue_from` method, you will need to call the `fail_job` method explicitly to log the job completion. For example:

```ruby
class MyJob < ActiveJob::Base
  def perform(param1, param2)
    # ...
  end

  rescue_from(Exception) do |exception|
    # ...
    fail_job(exception) #=> you need to call this method.
  end
end
```

## Testing

To run the specs you need to execute, **in the root path of the gem**, the following command:

```bash
bundle exec guard
```

You need to put **all your tests** in the `/active_job_log/spec/dummy/spec/` directory.

## Publishing

On master/main branch...

1. Change `VERSION` in `lib/gemaker/version.rb`.
2. Change `Unreleased` title to current version in `CHANGELOG.md`.
3. Run `bundle install`.
4. Commit new release. For example: `Releasing v0.1.0`.
5. Create tag. For example: `git tag v0.1.0`.
6. Push tag. For example: `git push origin v0.1.0`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Thank you [contributors](https://github.com/platanus/active_job_log/graphs/contributors)!

<img src="http://platan.us/gravatar_with_text.png" alt="Platanus" width="250"/>

Active Job Log is maintained by [platanus](http://platan.us).

## License

Active Job Log is © 2021 platanus, spa. It is free software and may be redistributed under the terms specified in the LICENSE file.
