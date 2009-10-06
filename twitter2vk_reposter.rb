#!/usr/bin/env ruby
# Check new Twitter statuses and repost it to VK.

require 'yaml'

if ARGV.empty? or '--help' == ARGV.first or '-h' == ARGV.first
  puts 'Usage: twitter2vk_reposter.rb CONFIG'
  puts 'Repost Twitter statuses to VK.com. Call twitter2vk script to create ' +
       'config and add cron task.'
  exit
end

config = YAML.load_file(ARGV.first)

last_message = if File.exists? config['last_message']
  File.read(config['last_message']).strip
end
