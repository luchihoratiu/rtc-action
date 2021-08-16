# frozen_string_literal: true

require_relative 'runner'
require_relative 'core_extensions/string'
require_relative 'helpers/message_formatter'

class Application
  class << self
    def run
      # runner = Runner.new
      # runner.execute
      # offenses = runner.offenses


      message = "Test message"
      STDOUT.puts message

      comment = { body: message }

      update_github_pr(comment) if ENV['UPDATE_PR'] == 'true'

      exit runner.exit_code if ENV['FORCE_ERROR_EXIT']
      exit 0
    end

    private

    def update_github_pr(comment)
      unless ENV['RTC_TOKEN']
        STDOUT.puts 'RTC_TOKEN not set, skipping PR update!'
      end
      STDOUT.puts 'Updating PR'.cyan

      require 'octokit'


      repo = ENV['GITHUB_REPOSITORY']
      # pr_number = ENV['GITHUB_REF'].delete('^0-9').to_i
      pr_number = 1
      event = 'COMMENT'

      STDOUT.puts repo
      STDOUT.puts pr_number
      STDOUT.puts event

      client = Octokit::Client.new(access_token: ENV['RTC_TOKEN'])
      
      pull_request = client.create_pull_request_review(repo, pr_number, comment)
      client.submit_pull_request_review(repo, pr_number, pull_request.id, event, {})
    end
  end
end

Application.run
