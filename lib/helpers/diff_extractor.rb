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
end
