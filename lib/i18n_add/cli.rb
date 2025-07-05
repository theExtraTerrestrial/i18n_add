# frozen_string_literal: true

require "optparse"
require "yaml"
require "fileutils"
require_relative "yaml_processor"

module I18nAdd
  ##
  # Command Line Interface for the i18n_add gem.
  #
  # Provides a clean interface for adding translation entries to YAML files
  # with support for multiple locales, custom file paths, and batch processing.
  class CLI
    def self.run(args = ARGV)
      new.run(args)
    end

    def run(args)
      return show_help if should_show_help?(args)

      begin
        config = parse_arguments(args)
        return show_help if config.help_requested

        validate_configuration(config)
        file_map = build_file_map(config)
        process_translations(file_map)
      rescue CLIError => e
        puts "\e[31m#{e.message}\e[0m"
        raise SystemExit.new(1)
      end
    end

    private

    def should_show_help?(args)
      args.first == "help" || args.empty? || args.include?("-h") || args.include?("--help")
    end

    def show_help
      puts help_message
    end

    def help_message
      <<~HELP
        Usage: i18n_add [OPTIONS] [-t <locale.key=value> ...] locale.key=value
            -t, --translation TRANSLATION     [Optional] Translation entry, can be specified multiple times. Format: locale.dot.separated.key=value
            -f, --file FILE                   [Optional] File path. If not specified, defaults to 'config/locales/%<locale>s/main.%<locale>s.yml' for each locale.
            -h, --help                        Show this help message and exit.
      HELP
    end

    def parse_arguments(args)
      config = CLIConfig.new

      option_parser = build_option_parser(config)
      option_parser.parse!(args)

      # Handle positional argument as translation if no -t flags given
      handle_positional_translation(config, args)

      config
    end

    def build_option_parser(config)
      OptionParser.new do |opts|
        opts.banner = "Usage: i18n_add help or i18n_add [options]"

        opts.on("-tVAL", "--translation VAL",
                "[Optional] Translation entry, can be specified multiple times. Format: locale.dot.separated.key=value") do |translation|
          config.add_translation(translation)
        end

        opts.on("-f", "--file FILE",
                "[Optional] File path. Supports %<locale>s as a placeholder for the locale. If not specified, defaults to 'config/locales/%<locale>s/main.%<locale>s.yml' for each locale.") do |file_path|
          config.file_template = file_path
        end

        opts.on("-h", "--help", "Show this help message and exit.") do
          # Set a flag that we can check later, don't call show_help here
          config.help_requested = true
        end
      end
    end

    def handle_positional_translation(config, args)
      return unless config.translations.empty? && args.size == 1 && TranslationEntry.valid_format?(args[0])

      config.add_translation(args.shift)
    end

    def validate_configuration(config)
      return unless config.translations.empty?

      raise CLIError, "No translations provided. Use -t or --translation."
    end

    def build_file_map(config)
      file_map_builder = FileMapBuilder.new(config)
      file_map_builder.build
    end

    def process_translations(file_map)
      processor = YamlProcessor.new
      processor.process_files(file_map)
    end

    # Configuration object to hold CLI options and translations
    class CLIConfig
      attr_reader :translations
      attr_accessor :file_template, :help_requested

      def initialize
        @translations = []
        @file_template = nil
        @help_requested = false
      end

      def add_translation(translation_string)
        @translations << translation_string
      end

      def has_custom_file_template?
        !@file_template.nil?
      end

      def default_file_template
        "config/locales/%<locale>s/main.%<locale>s.yml"
      end

      def effective_file_template
        @file_template || default_file_template
      end
    end

    # Represents a single translation entry with validation
    class TranslationEntry
      TRANSLATION_FORMAT = /^([a-z]{2})\.(.+?)=(.*)$/m

      attr_reader :locale, :key_path, :value

      def initialize(translation_string)
        @raw_string = translation_string
        parse_translation
      end

      def self.valid_format?(translation_string)
        translation_string =~ TRANSLATION_FORMAT
      end

      def to_hash
        { key_path: @key_path, value: @value }
      end

      private

      def parse_translation
        match = @raw_string.match(TRANSLATION_FORMAT)

        raise CLIError, "Invalid translation format: #{@raw_string}" unless match

        @locale = match[1]
        @key_path = match[2]
        @value = match[3]
      end
    end

    # Builds the file map structure from CLI configuration
    class FileMapBuilder
      def initialize(config)
        @config = config
      end

      def build
        file_map = {}

        @config.translations.each do |translation_string|
          entry = TranslationEntry.new(translation_string)
          file_path = generate_file_path(entry.locale)

          add_entry_to_file_map(file_map, file_path, entry)
        end

        file_map
      end

      private

      def generate_file_path(locale)
        @config.effective_file_template.gsub("%<locale>s", locale)
      end

      def add_entry_to_file_map(file_map, file_path, entry)
        file_map[file_path] ||= { locale: entry.locale, entries: [] }
        file_map[file_path][:entries] << entry.to_hash
      end
    end

    # Custom error class for CLI-specific errors
    class CLIError < StandardError; end
  end
end
