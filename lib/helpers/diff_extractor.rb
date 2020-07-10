# frozen_string_literal: true

class DiffExtractor
  DELIMITER = '--'

  class << self
    def call(diff_hash)
      extract_diff(diff_hash)
    end

    private

    def extract_diff(diff_hash)
      offenses = {
        new_offenses: {},
        fixed_offenses: {}
      }

      diff_hash.each do |line|
        cops = {}
        change_type = line[0]
        file, cop_name = line[1].split(DELIMITER)

        if line[2].is_a?(Hash)
          cops = line[2]
        else
          cops[cop_name] = line[2]
        end

        cops.each_pair do |cop, value|
          case change_type
          when '~'
            message = "changed from #{line[3]} to #{value}"
            if line[2] > line[3]
              (offenses[:new_offenses][file] ||= {})[cop] = message
            else
              (offenses[:fixed_offenses][file] ||= {})[cop] = message
            end
          when '-'
            (offenses[:new_offenses][file] ||= {})[cop] = "changed from 0 to #{value}"
          when '+'
            (offenses[:fixed_offenses][file] ||= {})[cop] = "changed from #{value} to 0"
          end
        end
      end

      offenses
    end
  end
end
