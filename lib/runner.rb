# frozen_string_literal: true

require_relative 'rubocop_loader'
require_relative 'rubocop_todo_parser'
require_relative 'rubocop_output_parser'

require 'hashdiff'
require 'open3'

class Runner
  DELIMITER = '--'

  attr_reader :offenses

  def initialize
    @offenses = {}
  end

  def exit_code
    offenses.any? ? 1 : 0
  end

  def success?
    offenses.empty?
  end

  def error_message
    error_message = ["New offenses:\n"]
    offenses.each_pair do |filename, offenses|
      error_message << "  - #{filename}:\n"
      offenses.each do |cop, value|
        error_message << "    - #{cop}: #{value}\n"
      end
    end
    error_message.join
  end

  def execute
    STDOUT.puts('Installing gems'.cyan)
    system('bundle install -j4 --retry 3 --quiet')
    STDOUT.puts("Success.\n\n".green)

    STDOUT.puts('Generating diff'.cyan)
    diff = Hashdiff.diff(pr_offenses, master_offenses, delimiter: DELIMITER)
    extract_form_diff(diff)
    STDOUT.puts("Done. \n\n".green)
  end

  private

  def files
    @files ||= `git diff --name-only HEAD HEAD~1`.split("\n").select { |e| e =~ /.rb/ }.join
  end

  def pr_offenses
    pr_raw_data = `rubocop --auto-gen-config --exclude-limit 2000 --format j #{files}`
    RubcopOutputParser.call(pr_raw_data)
  end

  def master_offenses
    Open3.capture3('git checkout . && git checkout HEAD^')

    master_raw_data = `rubocop --auto-gen-config --exclude-limit 2000 --format j #{files}`
    RubcopOutputParser.call(master_raw_data)
  end

  def extract_form_diff(diff)
    diff.each do |line|
      file, cop = line[1].split(DELIMITER)
      offenses[file] ||= {}
      if line[0] == '~'
        if line[2] > line[3]
          offenses[file][cop] = "changed from #{line[3]} to #{line[2]}"
        end
      else
        offenses[file][cop] = line[2]
      end
    end

    offenses
  end
end
