require 'rubygems'

PKG_VERSION = '0.3.3'

def common_spec(spec)
  spec.version = PKG_VERSION
  spec.summary = 'Atomatic repost Twitter statuses to VK (В Контакте).'
  spec.author = 'Andrey "A.I." Sitnik'
  spec.email = 'andrey@sitnik.ru'
  spec.rubyforge_project = 'twitter2vk'
end

installer_spec = Gem::Specification.new do |spec|
  spec.name = 'twitter2vk'
  spec.description = <<-EOF
    Console tool to create new config and cron task to automatic repost Twitter
    statuses to VK (В Контакте).
  EOF
  
  spec.add_dependency 'twitter2vk_reposter', "= #{PKG_VERSION}"
  spec.add_dependency 'activesupport'
  spec.add_dependency 'highline'
  spec.add_dependency 'rvk'
  spec.add_dependency 'oauth'
  spec.add_dependency 'twitter_oauth'
  spec.add_dependency 'r18n-desktop'
  
  spec.files = FileList[
    'bin/twitter2vk',
    'bin/i18n/ru.yml',
    'bin/i18n/en.yml',
    'README.markdown',
    'ChangeLog',
    'COPYING']
  spec.executable = 'twitter2vk'
  
  common_spec(spec)
end

responser_spec = Gem::Specification.new do |spec|
  spec.name = 'twitter2vk_reposter'
  spec.description = <<-EOF
    Server script to repost Twitter statuses to VK (В Контакте).
    Install twitter2vk to create config and cron task for it.
  EOF
  
  spec.add_dependency 'activesupport'
  spec.add_dependency 'json'
  spec.add_dependency 'rvk'
  spec.add_dependency 'twitter_oauth'
  
  spec.files = FileList[
    'bin/twitter2vk_reposter',
    'README.markdown',
    'ChangeLog',
    'COPYING']
  spec.executable = 'twitter2vk_reposter'
  
  common_spec(spec)
end

directory 'bin'

task :copy_bin => 'bin' do
  cp_r 'i18n', 'bin/i18n'
  cp 'twitter2vk.rb', 'bin/twitter2vk'
  cp 'twitter2vk_reposter.rb', 'bin/twitter2vk_reposter'
end

task :clobber_bin do
  rm_r 'bin' if File.exists? 'bin'
end

directory 'pkg'

file installer_spec.file_name => ['pkg', :copy_bin] do
  Gem::Builder.new(installer_spec).build
  mv installer_spec.file_name, "pkg/#{installer_spec.file_name}"
end

file responser_spec.file_name => ['pkg', :copy_bin] do
  Gem::Builder.new(responser_spec).build
  mv responser_spec.file_name, "pkg/#{responser_spec.file_name}"
end

desc 'Build the gem twitter2vk and twitter2vk_reposter'
task :gem => [installer_spec.file_name, responser_spec.file_name, :clobber_bin]

desc 'Delete all temporal files'
task :clobber do
  rm_r 'pkg' if File.exists? 'pkg'
end
