# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__ + "/../lib")

$stdout.sync = true

require "raven"
require "dependabot/setup"
require "dependabot/file_fetcher_job"
require "debug" if ENV["DEBUG"]

class UpdaterKilledError < StandardError; end

trap("TERM") do
  puts "Received SIGTERM"
  error = UpdaterKilledError.new("Updater process killed with SIGTERM")
  extra = { update_job_id: ENV.fetch("DEPENDABOT_JOB_ID", nil) }
  Raven.capture_exception(error, extra: extra)
  exit
end

begin
  Dependabot::FileFetcherJob.new.run
rescue Dependabot::RunFailure
  exit 1
end
