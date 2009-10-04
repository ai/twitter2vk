#!/usr/bin/env ruby
# Console tool to create new config.

if '--help' == ARGV.first or '-h' == ARGV.first
  puts 'Create config and cron task to repost Twitter statuses to VK.com'
  exit
end
