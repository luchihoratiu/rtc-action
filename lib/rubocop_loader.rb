# frozen_string_literal: true

class RubocopLoader
  class << self
    def call
      %w[rubocop rubocop-rspec rubocop-performance].each do |lib|
        begin
          require lib
        rescue LoadError => e
          STDOUT.puts e
        end
      end
    end
  end
end
