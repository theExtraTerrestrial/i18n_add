# frozen_string_literal: true

require 'optparse'
require 'yaml'
require 'fileutils'
require_relative 'yaml_processor'

module I18nAdd
  class CLI
    def self.run(args = ARGV)
      new.run(args)
    end

    def run(args)
      help_msg = <<~HELP
        Usage: i18n_add [OPTIONS] [-t <locale.key=value> ...] locale.key=value
            -t, --translation TRANSLATION     [Optional] Translation entry, can be specified multiple times. Format: locale.dot.separated.key=value
            -f, --file FILE                   [Optional] File path. If not specified, defaults to 'config/locales/%{locale}/main.%{locale}.yml' for each locale.
            -h, --help                        Show this help message and exit.
      HELP

      if args.first == 'help' || args.empty? || args.include?('-h') || args.include?('--help')
        puts help_msg
        return
      end

      options = { translations: [] }
      OptionParser.new do |opts|
        opts.banner = "Usage: i18n_add help or i18n_add [options]"
        opts.on('-tVAL', '--translation VAL', '[Optional] Translation entry, can be specified multiple times. Format: locale.dot.separated.key=value') { |v| options[:translations] << v }
        opts.on('-f', '--file FILE', '[Optional] File path. Supports %{locale} as a placeholder for the locale. If not specified, defaults to \'config/locales/%{locale}/main.%{locale}.yml\' for each locale.') { |v| options[:file] = v }
        opts.on('-h', '--help', 'Show this help message and exit.') do
          puts help_msg
          return
        end
      end.parse!(args)

      # If no -t given, but a single positional argument remains, treat it as a translation
      if options[:translations].empty? && args.size == 1 && args[0] =~ /^[a-z]{2}\..+?=.*/
        options[:translations] << args.shift
      end

      file_arg = options[:file]
      translations = options[:translations]

      if translations.empty?
        puts "\e[31mNo translations provided. Use -t or --translation.\e[0m"
        exit 1
      end

      # Parse all entries and group by file_path
      file_map = {}
      translations.each do |entry|
        if entry =~ /^([a-z]{2})\.(.+?)=(.+)$/
          locale, key_path, value = $1, $2, $3
          # Support only %{locale} in file_arg as a template
          if file_arg
            file_path = file_arg.gsub('%{locale}', locale)
          else
            file_path = "config/locales/#{locale}/main.#{locale}.yml"
          end
          file_map[file_path] ||= { locale: locale, entries: [] }
          file_map[file_path][:entries] << { key_path: key_path, value: value }
        else
          puts "\e[31mInvalid translation format: #{entry}\e[0m"
        end
      end

      processor = YamlProcessor.new
      processor.process_files(file_map)
    end
  end
end
