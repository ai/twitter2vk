#!/usr/bin/env ruby
# Check new Twitter statuses and repost it to VK.

$KCODE = 'u'

require 'rubygems'
require 'json'
require 'active_support'
require 'rvk'
require 'twitter_oauth'

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

def link(status)
  "http://twitter.com/#{status['user']['screen_name']}/status/#{status['id']}"
end

def format_text(status, format)
  format.gsub('%status%', status['text']).gsub('%url%', link(status)).mb_chars
end

def trim_text(text, length)
  if text.length > length
    text[0...(length - 1)] + '…'
  else
    text
  end
end

def format_status(status, config)
  last = trim_text(format_text(status, config['last'] || ''), 159)
  
  text = format_text(status, config['format'] || '%status%')
  Array(config['replace']).each do |replace|
    if :user_to_url == replace
      replace = [/@([a-zA-Z0-9_]+)/, 'http//twitter.com/\\1']
    end
    text.gsub!(replace[0], replace[1])
  end
  
  trim_text(text, 160 - last.length).to_s + last.to_s
end

config = YAML.load_file(ARGV.first)

last_message = if File.exists? config['last_message']
  File.read(config['last_message']).strip
end

twitter = TwitterOAuth::Client.new(:consumer_key => 'lGdk5MXwNqFyQ6glsog0g',
  :consumer_secret => 'jHfpLGY11clNSh9M0Fqnjl7fzqeHwrKSWTBo4i8TUcE',
  :token => config['twitter_token'], :secret => config['twitter_secret'])
statuses = twitter.user_timeline(
  last_message ? { :since_id => last_message } : { :count => 1})

unless statuses.empty?
  vk = Vkontakte::User.new(config['vk_session'])
  
  last_message_id = nil
  statuses.reverse.each do |status|
    next unless repost? status['text'], config
    text = format_status(status, config)
    last_message_id = status['id']
    vk.set_status(text)
    break
  end
  
  File.open(config['last_message'], 'w') { |io| io << last_message_id }
end
