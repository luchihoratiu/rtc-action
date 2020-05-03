# frozen_string_literal: true

class MessageFormatrer
  NO_CHANGES = 'No changes detected.'

  class << self
    def call(data)
      @data = data
      @output = []

      new_offenses_output if new_offenses.any?
      fixed_offenses_output if fixed_offenses.any?
      return output.join if output.any?

      NO_CHANGES
    end

    private

    attr_accessor :output
    attr_reader :data

    def new_offenses
      data[:new_offenses] || {}
    end

    def fixed_offenses
      data[:fixed_offenses] || {}
    end

    def fixed_offenses_output
      output << "\nFixed_offenses:\n"
      offenses_output(fixed_offenses)
    end

    def new_offenses_output
      output << "\nNew offenses:\n"
      offenses_output(new_offenses)
    end

    def offenses_output(offenses_data)
      offenses_data.each_pair do |filename, offenses|
        output << "  - #{filename}:\n"
        offenses.each do |cop, value|
          output << "    - #{cop}: #{value}\n"
        end
      end
    end
  end
end
