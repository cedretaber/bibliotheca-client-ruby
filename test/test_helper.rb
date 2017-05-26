require 'simplecov'

SimpleCov.start do
  add_filter '/.bundle'
  add_filter '/test/'

  # add_group 'Binaries', '/bin/'
  # add_group 'Libraries', '/lib/'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
