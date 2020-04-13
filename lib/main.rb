# frozen_string_literal: true

require_relative 'runner'
require_relative 'core_extensions/string'

class Application
  class << self
    def run
      runner = Runner.new
      runner.execute
      if runner.success?
        msg = 'No new offenses found!'
        STDOUT.puts(msg.green)

        comment = { body: "#{msg} :thumbsup:" }
      else
        error_message = runner.error_message
        STDOUT.puts error_message

        comment = { body: error_message.no_colors }
      end

      update_github_pr(comment) if ENV['UPDATE_PR'] == 'true'

      exit runner.exit_code
    end

    private

    def update_github_pr(comment)
      unless ENV['RTC_TOKEN']
        STDOUT.puts 'RTC_TOKEN not set, skipping PR update!'
      end
      STDOUT.puts 'Updating PR'.cyan

      require 'octokit'

      client = Octokit::Client.new(access_token: ENV['RTC_TOKEN'])

      repo = ENV['GITHUB_REPOSITORY']
      pr_number = ENV['GITHUB_REF'].delete('^0-9').to_i
      event = 'COMMENT'

      pull_request = client.create_pull_request_review(repo, pr_number, comment)
      client.submit_pull_request_review(repo, pr_number, pull_request.id, event, {})
    end
  end
end

Application.run
