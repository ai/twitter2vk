#!/usr/bin/env ruby
# Console tool to create new config and cron task.

require 'rubygems'
require 'highline/import'
require 'r18n-desktop'

require 'fileutils'
require 'net/http'
require 'yaml'
require 'pathname'

trap('INT') do
  puts
  exit
end

i18n = R18n.from_env(File.join(File.dirname(__FILE__), 'i18n'))

if '--help' == ARGV.first or '-h' == ARGV.first
  say i18n.help
  exit
end

config = {}

HighLine.track_eof = false

email    = ask(i18n.vk.email)
password = ask(i18n.vk.password) { |q| q.echo = false }

resource = Net::HTTP.post_form(URI.parse('http://login.vk.com/'), 
    { 'email' => email, 'pass' => password, 'vk' => '', 'act' => 'login' })
if resource.body.empty?
  say i18n.vk.error
  exit
end

config['vk_session'] = resource.body.match(/value='([a-z0-9]+)'/)[1]
config['twitter']    = ask(i18n.twitter)

config['exclude'] = ['#novk', :reply]
config['include'] = ['#vk']
config['format'] = '%status%'
config['replace'] = []

path = ask(i18n.config) { |q| q.default = "./#{config['twitter']}.yml" }
path = File.expand_path(path)

config['last_message'] = ask(i18n.last_message) do |q|
  q.default = "./#{config['twitter']}_last_message"
end
config['last_message'] = File.expand_path(config['last_message'])

File.open(path, 'w') { |io| io << config.to_yaml }
FileUtils.chmod 0700, path

period = ask(i18n.period) { |q| q.default = 5 }

reposter = if File.expand_path(__FILE__).start_with? Gem.dir
  File.join(Gem.bindir, 'twitter2vk_reposter')
elsif File.exists? File.join(File.dirname(__FILE__), 'twitter2vk_reposter')
  File.expand_path File.join(File.dirname(__FILE__), 'twitter2vk_reposter.rb')
else
  'twitter2vk_reposter'
end

task = "*/#{period} *  *   *   *      #{reposter} #{path}"

if agree(i18n.cron) { |q| q.default = 'yes' }
  tasks = `crontab -l`
  if tasks.empty?
    tasks << "# m h  dom mon dow   command\n"
  elsif tasks[-1..-1] != "\n"
    tasks << "\n"
  end
  tasks << task
  `echo '#{tasks}' | crontab -`
  say i18n.success.cron
else
  say i18n.success.print(task)
end

