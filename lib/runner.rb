# frozen_string_literal: true

require_relative 'rubocop_loader'
require_relative 'rubocop_todo_parser'

class Runner
  attr_reader :errors

  def initialize
    RubocopLoader.call
    @errors = {}
  end

  def status
    errors.any? ? 1 : 0
  end

  def success?
    errors.empty?
  end

  def error_message
    error_message = []
    errors.each_pair do |key, value|
      error_message << "Error: #{key} has #{value} new offenses"
    end
    error_message.join("\n")
  end

  def execute
    STDOUT.puts('Getting current offenses')
    actual_offenses = RubocopTodoParser.call
    STDOUT.puts("Done.\n\n")

    STDOUT.puts('Running rubocop --auto-gen-config')
    system('bundle exec rubocop --auto-gen-config &> /dev/null')

    STDOUT.puts('Getting new offenses')
    commit_offenses = RubocopTodoParser.call
    STDOUT.puts("Done.\n\n")

    commit_offenses.each_pair do |key, value|
      diff = value - actual_offenses.fetch(key, 0)
      errors[key] = diff if diff.positive?
    end
  end
end
