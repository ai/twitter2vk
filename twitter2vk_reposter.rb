#!/usr/bin/env ruby
# Check new Twitter statuses and repost it to VK.

require 'rubygems'
require 'json'

require 'yaml'
require 'open-uri'
require 'net/http'

if ARGV.empty? or '--help' == ARGV.first or '-h' == ARGV.first
  puts 'Usage: twitter2vk_reposter.rb CONFIG'
  puts 'Repost Twitter statuses to VK.com. Call twitter2vk script to create ' +
       'config and add cron task.'
  exit
end

def check(text, pattern)
  pattern = /^@\w/ if :reply == pattern
  
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

def format_status(status, format)
  format = '%status%' unless format
  text = format.gsub('%status%', status['text']).gsub('%url%',
      "http://twitter.com/#{status['user']['screen_name']}/#{status['id']}")
  text = text[0...159] + '…' if text.length > 160
  text
end

def set_status_to_vk(text, session, activityhash)
  url = URI.parse('http://vk.com/profile.php')
  request = Net::HTTP::Post.new(url.path)
  request.set_form_data({'setactivity' => text, 'activityhash' => activityhash})
  request['cookie'] = "remixsid=#{session}"
  
  Net::HTTP.new(url.host, url.port).start { |http| http.request(request) }
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
    text = format_status(status, config['format'])
    next unless repost? text, config
    set_status_to_vk(text, config['vk_session'], activityhash)
    sleep 10 unless statuses.last == status
  end
  
  File.open(config['last_message'], 'w') { |io| io << statuses.first['id'] }
end
