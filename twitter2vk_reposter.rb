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

def check(text, pattern)
  if pattern.is_a? String
    text.index(pattern)
  elsif pattern.is_a? Regexp
    text =~ pattern
  end
end

def repost?(text, config)
  Array(config['exclude']).each do |pattern|
    if check(text, pattern)
      Array(config['include']).each do |pattern|
        return true if check(text, pattern)
      end
      return false
    end
  end
  true
end

def load_vk_activityhash(session)
  request = open('http://vk.com/profile.php', 'Cookie' => "remixsid=#{session}")
  profile = request.read.to_s
  profile.match(/<input type='hidden' id='activityhash' value='([^']+)'>/)[1]
end

def set_status_to_vk(text, session, activityhash)
  
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
  activityhash = load_vk_activityhash(config['vk_session'])
  
  statuses.each do |status|
    next unless repost? status['text'], config
    set_status_to_vk(status['text'], config['vk_session'], activityhash)
  end
  
  File.open(config['last_message'], 'w') { |io| io << statuses.first['id'] }
end
