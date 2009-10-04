#!/usr/bin/env ruby
# Console tool to create new config.

require 'rubygems'
require 'highline/import'

require 'fileutils'
require 'net/http'
require 'yaml'
require 'pathname'

trap('INT') do
  puts
  exit
end

if '--help' == ARGV.first or '-h' == ARGV.first
  say 'Create config and cron task to repost Twitter statuses to VK.com.'
  exit
end

config = {}

HighLine.track_eof = false

email    = ask('VK e-mail: ')
password = ask('VK password: ') { |q| q.echo = false }

resource = Net::HTTP.post_form(URI.parse('http://login.vk.com/'), 
    { 'email' => email, 'pass' => password, 'vk' => '', 'act' => 'login' })
if resource.body.empty?
  say 'Error: VK e-mail or password is incorrect.'
  exit
end

config['vk_session'] = resource.body.match(/value='([a-z0-9]+)'/)[1]
config['twitter']    = ask('Twitter name: ')

config['exclude'] = ['#novk', /@\w/]
config['include'] = nil

path = ask('Config path: ') { |q| q.default = "./#{config['twitter']}.yml" }

File.open(path, 'w') { |io| io << config.to_yaml }
FileUtils.chmod 0700, path

reposter = Pathname.new(__FILE__).dirname.expand_path + 'twitter2vk_reposter.rb'
period = ask('Check period in minutes: ') { |q| q.default = 5 }

`echo "#{period} * * * * #{reposter} #{File.expand_path(path)}" | crontab -`
say 'Config and cron task are created.'
