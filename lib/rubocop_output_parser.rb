# frozen_string_literal: true

require 'json'

class RubcopOutputParser
  class << self
    def call(data)
      parsed_data = parse_json(data)
      extract_data(parsed_data)
    end

    private

    EXTRA_START = /\A.+?(?={\\\"metadata\\\")/mi.freeze
    EXTRA_END = 'Created .rubocop_todo.yml.\n'

    def parse_json(raw_data)
      raw_data.sub!(Regexp.new(EXTRA_END), '')
      raw_data = raw_data.split("\n").last
      begin
        JSON.parse(raw_data)
      rescue JSON::ParserError, TypeError
        {}
      end
    end

    def extract_data(rubocop_hash)
      extracted_data = {}
      (rubocop_hash['files'] || []).each do |file|
        file_path = file['path']
        extracted_data[file_path] = {}

        (file['offenses'] || []).each do |offense|
          cop_name = offense['cop_name']
          if extracted_data[file_path][cop_name]
            extracted_data[file_path][cop_name] += 1
          else
            extracted_data[file_path][cop_name] = 1
          end
        end
      end
      extracted_data.select! { |_, value| value.any? }
      extracted_data
    end
  end
end

# raw_data = `rubocop --auto-gen-config --exclude-limit 2000 --format j spec/facter`

# extracted_data = RubcopOutputParser.call(raw_data)
# pp extracted_data
