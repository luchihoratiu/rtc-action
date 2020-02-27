# frozen_string_literal: true

class RubocopTodoParser
  class << self
    def call
      offense_lines = rubocop_todo_lines.select! do |el|
        el =~ Regexp.new(cops)
      end

      offense_lines = offense_lines.map(&:chomp).each_slice(2).map do |el|
        [el[0].gsub!('# Offense count: ', '').to_i, el[1].delete!(':')]
      end

      offense_lines.map!(&:reverse)

      Hash[offense_lines]
    end

    private

    def cops
      cops = RuboCop::Cop::Cop.all.map!(&:to_s).map! do |el|
        el.gsub!('RuboCop::Cop::', '')
          .gsub!('::', '/')
      end.join('|')
      cops << '|Offense count:'
    end

    def rubocop_todo_lines
      File.readlines("#{Dir.pwd}/.rubocop_todo.yml")
    rescue Errno::ENOENT
      STDOUT.puts('.rubocop_todo.yml not found, stopping')
      exit 1
    end
  end
end
