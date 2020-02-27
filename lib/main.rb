# frozen_string_literal: true

require_relative 'runner'
require_relative 'core_extensions/string'

runner = Runner.new
runner.execute

if runner.success?
  STDOUT.puts('No new offenses found'.green)
else
  STDOUT.puts runner.error_message.red
end

exit runner.status
