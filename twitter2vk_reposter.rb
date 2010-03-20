#!/usr/bin/env ruby
# Check new Twitter statuses and repost it to VK.

$KCODE = 'u'

require 'rubygems'
require 'json'
require 'active_support'
require 'rvk'

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

def format_status(status, config)
  format = config['format'] || '%status%'
  text = format.gsub('%status%', status['text']).gsub('%url%',
      "twitter.com/#{status['user']['screen_name']}/#{status['id']}")
  
  Array(config['replace']).each do |replace|
    replace = [/@([a-zA-Z0-9_]+)/, 'twitter.com/\\1'] if :user_to_url == replace
    text.gsub!(replace[0], replace[1])
  end
  
  text = text.mb_chars
  text = text[0...159] + '…' if text.length > 160
  text.to_s
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
  vk = Vkontakte::User.new(config['vk_session'])
  
  last_message_id = nil
  statuses.reverse.each do |status|
    text = format_status(status, config)
    last_message_id = status['id']
    next unless repost? text, config
    vk.set_status(text)
    break
  end
  
  File.open(config['last_message'], 'w') { |io| io << last_message_id }
end
