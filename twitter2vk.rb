#!/usr/bin/env ruby
# Console tool to create new config.

require 'rubygems'
require 'highline/import'
require 'net/http'

if '--help' == ARGV.first or '-h' == ARGV.first
  say 'Create config and cron task to repost Twitter statuses to VK.com'
  exit
end

HighLine.track_eof = false

email    = ask('VK e-mail: ')
password = ask('VK password: ') { |q| q.echo = false }

resource = Net::HTTP.post_form(URI.parse('http://login.vk.com/'), 
    { 'email' => email, 'pass' => password, 'vk' => '', 'act' => 'login' })

if resource.body.empty?
  say 'Error: VK e-mail or password is incorrect'
  exit
end
session_id = resource.body.match(/value='([a-z0-9]+)'/)[1]

twitter = ask('Twitter name: ')
