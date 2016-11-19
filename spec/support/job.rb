# frozen_string_literal: true
module JobHelper
  def clear_jobs
    enqueued_jobs.clear
  end

  def enqueued_jobs
    ActiveJob::Base.queue_adapter.enqueued_jobs
  end
end
