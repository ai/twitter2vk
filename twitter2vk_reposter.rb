#!/usr/bin/env ruby
# encoding: utf-8
# Check new Twitter statuses and repost it to VK.

$KCODE = 'u' if '1.8.' == RUBY_VERSION[0..3]

require 'rubygems'
require 'active_support'
require 'active_support/core_ext/string/multibyte'
require 'rvk'
require 'twitter_oauth'

require 'yaml'
require 'open-uri'
require 'net/http'

if ARGV.empty? or '--help' == ARGV.first or '-h' == ARGV.first
  puts 'Usage: twitter2vk_reposter.rb CONFIG'
  puts 'Repost Twitter statuses to VK.com. Call twitter2vk script to create ' +
       'config and add cron task.'
  exit 0
end

def check(status, pattern)
  return status.has_key?('retweeted_status') if :retweet == pattern
  
  pattern = /^@\w/ if :reply == pattern
  if pattern.is_a? String
    status['text'].index(pattern)
  elsif pattern.is_a? Regexp
    status['text'] =~ pattern
  end
end

def repost?(status, config)
  Array(config['exclude']).each do |pattern|
    if check(status, pattern)
      Array(config['include']).each do |pattern|
        return true if check(status, pattern)
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
  text = status['text'].gsub('&lt;', '<').gsub('&gt;', '>').gsub('&amp;', '&')
  format.gsub('%status%', text).
         gsub('%url%', link(status)).
         gsub('%author%', '@' + status['user']['screen_name']).mb_chars
end

def trim_text(text, length)
  if text.length > length
    text[0...(length - 1)] + '…'
  else
    text
  end
end

VK_MAX_STATUS = 255

def format_status(status, config)
  last = trim_text(format_text(status, config['last']), VK_MAX_STATUS)
  
  if status.has_key?('retweeted_status')
    text = format_text(status['retweeted_status'], config['retweet'])
  else
    text = format_text(status, config['format'])
  end
  Array(config['replace']).each do |replace|
    if :user_to_url == replace
      replace = [/@([a-zA-Z0-9_]+)/, 'http//twitter.com/\\1']
    end
    text.gsub!(replace[0], replace[1])
  end
  
  trim_text(text, VK_MAX_STATUS - last.length).to_s + last.to_s
end

default = {
  'format'  => '%status%',
  'last'    => '',
  'retweet' => 'RT %author%: %status%'
}
config = default.merge(YAML.load_file(ARGV.first))

missed = %w{twitter_token twitter_secret last_message vk_session} - config.keys
unless missed.empty?
  STDERR.puts "Config #{ARGV.first} has't required options: " +
              "#{missed.join(', ')}."
  exit 1
end

last_message = if File.exists? config['last_message']
  File.read(config['last_message']).strip
end
last_message = nil unless last_message =~ /^\d/

begin
  twitter = TwitterOAuth::Client.new(:consumer_key => 'lGdk5MXwNqFyQ6glsog0g',
    :consumer_secret => 'jHfpLGY11clNSh9M0Fqnjl7fzqeHwrKSWTBo4i8TUcE',
    :token => config['twitter_token'], :secret => config['twitter_secret'])
  if last_message
    query = { :since_id => last_message }
  else
    query = { :count => 1 }
  end
  statuses = twitter.user_timeline(query) + twitter.retweeted_by_me(query)
  statuses.sort! { |a, b| a['id'] <=> b['id'] }
rescue JSON::ParserError => e
  exit 1
end

statuses = [statuses.last] unless last_message

unless statuses.empty?
  vk = Vkontakte::User.new(config['vk_session'])
  
  last_message_id = nil
  statuses.each do |status|
    next unless repost? status, config
    text = format_status(status, config)
    last_message_id = status['id']
    vk.set_status(text)
    break
  end
  
  if last_message_id
    File.open(config['last_message'], 'w') { |io| io << last_message_id }
  end
end
