#!/usr/bin/env ruby
# Check new Twitter statuses and repost it to VK.

require 'rubygems'
require 'json'

require 'yaml'
require 'open-uri'

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

query = last_message ? "since_id=#{last_message}" : 'count=1'
request = open('http://twitter.com/statuses/user_timeline/' +
               "#{config['twitter']}.json?#{query}")
statuses = JSON.parse(request.read.to_s)

unless statuses.empty?
  statuses.each do |status|
    
  end
  
  File.open(config['last_message'], 'w') { |io| io << statuses.first['id'] }
end
