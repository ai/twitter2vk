#!/usr/bin/env ruby
# Console tool to create new config and cron task.

require 'rubygems'
require 'highline/import'
require 'r18n-desktop'
require 'active_support'
require 'rvk'
require 'oauth'
require 'twitter_oauth'

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

begin
  vk = Vkontakte::User.new(email, password)
rescue Vkontakte::VkontakteError => e
  say i18n.vk.error
  exit
end
config['vk_session'] = vk.session

KEY = 'lGdk5MXwNqFyQ6glsog0g'
SECRET = 'jHfpLGY11clNSh9M0Fqnjl7fzqeHwrKSWTBo4i8TUcE'
consumer = OAuth::Consumer.new(KEY, SECRET, :site => 'http://twitter.com/')
request = consumer.get_request_token
pin = ask(i18n.twitter(request.authorize_url))
access = request.get_access_token(:oauth_verifier => pin)

config['twitter_token'] = access.token
config['twitter_secret'] = access.secret

twitter = TwitterOAuth::Client.new(:consumer_key => KEY,
  :consumer_secret => SECRET, :token => access.token, :secret => access.secret)

screen_name = twitter.info['screen_name']
path = ask(i18n.config) { |q| q.default = "./#{screen_name}.yml" }
path = File.expand_path(path)

log = ask(i18n.log) { |q| q.default = "./#{screen_name}.log" }
log = File.expand_path(log)

if File.exists? path
  (config = YAML.load_file(path).merge(config)) rescue puts i18n.update_error
end

default = {
  'exclude' => ['#novk', :reply],
  'include' => ['#vk'],
  'replace' => [],
  'format'  => '%status%',
  'last'    => '',
  'retweet' => 'RT %author%: %status%'
}
config = default.merge(config)

config['last_message'] = ask(i18n.last_message) do |q|
  q.default = "./#{screen_name}_last_message"
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

task = "*/#{period} *  *   *   *      #{reposter} #{path} 2>> #{log}"

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
