#!/usr/bin/env ruby
# Console tool to create new config.

require 'rubygems'
require 'highline/import'
require 'net/http'
require 'yaml'

trap('INT') do
  puts
  exit
end

if '--help' == ARGV.first or '-h' == ARGV.first
  say 'Create config and cron task to repost Twitter statuses to VK.com'
  exit
end

config = {}

HighLine.track_eof = false

email    = ask('VK e-mail: ')
password = ask('VK password: ') { |q| q.echo = false }

resource = Net::HTTP.post_form(URI.parse('http://login.vk.com/'), 
    { 'email' => email, 'pass' => password, 'vk' => '', 'act' => 'login' })
if resource.body.empty?
  say 'Error: VK e-mail or password is incorrect'
  exit
end

config['vk_session'] = resource.body.match(/value='([a-z0-9]+)'/)[1]
config['twitter']    = ask('Twitter name: ')

config['exclude'] = ['#novk', /@[\w\d]/]
config['include'] = ''

path = ask('Config path: ') { |q| q.default = "./#{config['twitter']}.yml" }

File.open(path, 'w') { |io| io << config.to_yaml }
