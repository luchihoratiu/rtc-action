# frozen_string_literal: true

require_relative 'rubocop_loader'
require_relative 'rubocop_todo_parser'

class Runner
  attr_reader :errors

  def initialize
    @errors = {}
  end

  def exit_code
    errors.any? ? 1 : 0
  end

  def success?
    errors.empty?
  end

  def error_message
    error_message = []
    errors.each_pair do |key, value|
      error_message << "Error: #{key} has #{value} new offenses".red
    end
    error_message.join("\n")
  end

  def execute
    STDOUT.puts('Installing gems')
    system('bundle install -j4 --retry 3 --quiet')
    STDOUT.puts("Success.\n\n".green)

    RubocopLoader.call

    STDOUT.puts('Getting current offenses')
    actual_offenses = RubocopTodoParser.call
    STDOUT.puts("Success.\n\n".green)

    STDOUT.puts('Running rubocop --auto-gen-config')
    system('bundle exec rubocop --auto-gen-config --exclude-limit 0')

    STDOUT.puts('Getting new offenses')
    commit_offenses = RubocopTodoParser.call
    STDOUT.puts("Success.\n\n".green)

    commit_offenses.each_pair do |key, value|
      diff = value - actual_offenses.fetch(key, 0)
      errors[key] = diff if diff.positive?
    end
  end
end
