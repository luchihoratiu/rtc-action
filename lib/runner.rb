# frozen_string_literal: true

require 'open3'
require 'hashdiff'

require_relative 'helpers/rubocop_loader'
require_relative 'helpers/rubocop_todo_parser'
require_relative 'helpers/rubocop_output_parser'
require_relative 'helpers/diff_extractor'

class Runner
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

  def execute
    STDOUT.puts('Installing gems'.cyan)
    system('bundle install -j4 --retry 3 --quiet')
    STDOUT.puts("Success.\n\n".green)

    if files.any?
      STDOUT.puts("Inspecting:\n- #{files.join("\n- ")}".cyan)

      STDOUT.puts("\nGenerating diff".cyan)

      diff_hash = Hashdiff.diff(
        pr_offenses, master_offenses,
        delimiter: DiffExtractor::DELIMITER
      )
      self.offenses = DiffExtractor.call(diff_hash)

      STDOUT.puts("Done. \n\n".green)
    else
      STDOUT.puts('No files to inspect'.cyan)
    end
  end

  private

  attr_writer :offenses

  def files
    require 'pathname'
    @files ||= `git diff --name-only --diff-filter=M HEAD HEAD~1`.split("\n").select do |file|
      file =~ /.rb/ && rubocop_excluded.none? { |excluded| Pathname.new(file).fnmatch?(excluded) }
    end
  end

  def pr_offenses
    pr_raw_data = `bundle exec rubocop --auto-gen-config --exclude-limit 2000 --format j #{files.join(' ')}`
    RubcopOutputParser.call(pr_raw_data)
  end

  def master_offenses
    Open3.capture3('git checkout . && git checkout HEAD^')

    master_raw_data = `bundle exec rubocop --auto-gen-config --exclude-limit 2000 --format j #{files.join(' ')}`
    RubcopOutputParser.call(master_raw_data)
  end

  def new_offenses
    offenses[:new_offenses] || {}
  end

  def fixed_offenses
    offenses[:fixed_offenses] || {}
  end

  def rubocop_excluded
    require 'psych'
    Psych.load_file("#{Dir.pwd}/.rubocop.yml")&.dig('AllCops', 'Exclude')
  rescue StandardError
    []
  end
end
