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
    new_offenses.any? ? 1 : 0
  end

  def success?
    new_offenses.empty?
  end

  def message
    message = ["New offenses:\n".bold]
    new_offenses.each_pair do |filename, offenses|
      message << "  - #{filename}:\n"
      offenses.each do |cop, value|
        message << "    - #{cop}: #{value}\n".italic
      end
    end

    message << "\nFixed_offenses:\n".bold
    fixed_offenses.each_pair do |filename, offenses|
      message << "  - #{filename}:\n"
      offenses.each do |cop, value|
        message << "    - #{cop}: #{value}\n".italic
      end
    end

    message.join
  end

  def execute
    STDOUT.puts('Installing gems'.cyan)
    system('bundle install -j4 --retry 3 --quiet')
    STDOUT.puts("Success.\n\n".green)

    if files.any?
      STDOUT.puts("inspecting:\n- #{files.join("\n- ")}".cyan)

      STDOUT.puts("\nGenerating diff".cyan)
      diff = Hashdiff.diff(pr_offenses, master_offenses, delimiter: DELIMITER)
      self.offenses = extract_form_diff(diff)
      STDOUT.puts("Done. \n\n".green)
    else
      STDOUT.puts('No files to inspect'.cyan)
    end
  end

  private

  attr_writer :offenses

  def files
    @files ||= `git diff --name-only HEAD HEAD~1`.split("\n").select { |e| e =~ /.rb/ }
  end

  def pr_offenses
    pr_raw_data = `rubocop --auto-gen-config --exclude-limit 2000 --format j #{files.join(' ')}`
    RubcopOutputParser.call(pr_raw_data)
  end

  def master_offenses
    Open3.capture3('git checkout . && git checkout HEAD^')

    master_raw_data = `rubocop --auto-gen-config --exclude-limit 2000 --format j #{files.join(' ')}`
    RubcopOutputParser.call(master_raw_data)
  end

  def new_offenses
    offenses[:new_offenses] || {}
  end

  def fixed_offenses
    offenses[:fixed_offenses] || {}
  end

  def extract_form_diff(diff)
    offenses = {
      new_offenses: {},
      fixed_offenses: {}
    }

    diff.each do |line|
      file, cop = line[1].split(DELIMITER)

      case line[0]
      when '~'
        message = "changed from #{line[3]} to #{line[2]}"
        if line[2] > line[3]
          (offenses[:new_offenses][file] ||= {})[cop] = message
        else
          (offenses[:fixed_offenses][file] ||= {})[cop] = message
        end
      when '-'
        (offenses[:new_offenses][file] ||= {})[cop] = "changed from 0 to #{line[2]}"
      when '+'
        (offenses[:fixed_offenses][file] ||= {})[cop] = "changed from 0 to #{line[2]}"
      end
    end

    offenses
  end
end
