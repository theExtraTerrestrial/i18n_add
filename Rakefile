# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

RuboCop::RakeTask.new

task default: %i[test rubocop]

# Version management tasks
namespace :version do
  desc "Show current version"
  task :show do
    require_relative "lib/i18n_add/version"
    puts "Current version: #{I18nAdd::VERSION}"
  end

  desc "Bump patch version"
  task :patch do
    bump_version(:patch)
  end

  desc "Bump minor version"
  task :minor do
    bump_version(:minor)
  end

  desc "Bump major version"
  task :major do
    bump_version(:major)
  end
end

def bump_version(type)
  require_relative "lib/i18n_add/version"
  current = I18nAdd::VERSION
  major, minor, patch = current.split(".").map(&:to_i)

  case type
  when :patch
    patch += 1
  when :minor
    minor += 1
    patch = 0
  when :major
    major += 1
    minor = 0
    patch = 0
  end

  new_version = "#{major}.#{minor}.#{patch}"

  # Update version file
  version_file = "lib/i18n_add/version.rb"
  content = File.read(version_file)
  content.gsub!(/"#{current}"/, "\"#{new_version}\"")
  File.write(version_file, content)

  puts "Version bumped from #{current} to #{new_version}"
  puts "Don't forget to:"
  puts "1. Update CHANGELOG.md"
  puts "2. Commit changes: git add -A && git commit -m 'chore: bump version to #{new_version}'"
  puts "3. Tag release: git tag -a v#{new_version} -m 'Release version #{new_version}'"
  puts "4. Push: git push && git push --tags"
end
