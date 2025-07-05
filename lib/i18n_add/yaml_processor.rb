# frozen_string_literal: true

module I18nAdd
  class YamlProcessor
    ##
    # Processes multiple YAML translation files with their respective locale configurations.
    #
    # This is the main entry point for the YAML processor. It handles batch processing
    # of translation entries across multiple files, ensuring that each file is properly
    # updated with new translation keys while preserving existing content and structure.
    #
    # The method creates necessary directory structures, handles file creation if files
    # don't exist, and maintains proper YAML formatting throughout the process.
    #
    # @param file_map [Hash<String, Hash>] A hash mapping file paths to their configurations
    # @option file_map [String] :locale The locale identifier (e.g., 'en', 'es', 'fr')
    # @option file_map [Array<Hash>] :entries Array of translation entries to process
    # @option entries [String] :key_path Dot-separated key path (e.g., 'app.navigation.home')
    # @option entries [String] :value The translation value
    #
    # @return [void] This method doesn't return a value but outputs processing status
    #
    # @example Processing translations for multiple locales
    #   processor = YamlProcessor.new
    #   file_map = {
    #     'config/locales/en/main.en.yml' => {
    #       locale: 'en',
    #       entries: [
    #         { key_path: 'app.title', value: 'My Application' },
    #         { key_path: 'nav.home', value: 'Home' }
    #       ]
    #     },
    #     'config/locales/es/main.es.yml' => {
    #       locale: 'es',
    #       entries: [
    #         { key_path: 'app.title', value: 'Mi Aplicación' },
    #         { key_path: 'nav.home', value: 'Inicio' }
    #       ]
    #     }
    #   }
    #   processor.process_files(file_map)
    #
    # @example Processing a single file
    #   file_map = {
    #     'translations.yml' => {
    #       locale: 'en',
    #       entries: [{ key_path: 'greeting', value: 'Hello World' }]
    #     }
    #   }
    #   processor.process_files(file_map)
    #
    # @note The method automatically creates directory structures and files if they don't exist
    # @note Existing YAML content is preserved and new keys are properly merged
    # @note Console output shows processing progress and completion status
    #
    # @see #process_single_file
    # @since 1.0.0
    def process_files(file_map)
      file_map.each do |file_path, config|
        process_single_file(file_path, config)
      end
      puts "Processed #{file_map.size} files successfully."
    end

    private

    def process_single_file(file_path, config)
      locale = config[:locale]
      entries = config[:entries]
      @file_contents = load_file_contents(file_path)

      entries.each do |entry|
        process_entry(locale: locale, entry: entry)
        puts "\e[32m✓ Processed #{entry[:key_path]} in #{file_path}\e[0m"
      end

      save_file_contents(file_path, @file_contents)
      puts "\e[32m✓ Updated #{file_path}\e[0m"
    end

    def load_file_contents(file_path)
      # Create directory structure if it doesn't exist
      FileUtils.mkdir_p(File.dirname(file_path))

      # If file doesn't exist, create it as empty (processor will handle locale detection)
      File.write(file_path, "") unless File.exist?(file_path)

      File.readlines(file_path, chomp: false)
    end

    def save_file_contents(file_path, file_contents)
      File.write(file_path, file_contents.join)
    end

    def process_entry(locale:, entry:)
      translation = TranslationEntry.new(
        key_path: entry[:key_path],
        value: entry[:value]
      )

      # Ensure locale exists in file
      ensure_locale_exists(locale)

      locale_position = find_locale_position(locale)
      processor_state = ProcessorState.new(locale_position, @file_contents.size - 1)

      translation.keys.each_with_index do |key, level|
        key_context = KeyContext.new(
          key: key,
          level: level,
          translation: translation,
          indentation: calculate_indentation(level)
        )

        process_key_level(state: processor_state, context: key_context)
      end
    end

    def ensure_locale_exists(locale)
      return if @file_contents.any? { |line| line.start_with?("#{locale}:") }

      # Add locale at the beginning if file is empty, or at the end if it has content
      if @file_contents.empty? || @file_contents.all? { |line| line.strip.empty? }
        @file_contents.clear
        @file_contents << "#{locale}:\n"
      else
        @file_contents << "#{locale}:\n"
      end
    end

    def find_locale_position(locale)
      position = @file_contents.find_index { |line| line.start_with?("#{locale}:") }
      # If locale not found, assume it's the first line (index 0)
      position || 0
    end

    def process_key_level(state:, context:)
      lookup_key = "#{context.indentation}#{context.key}:"
      existing_position = find_existing_key(lookup_key)

      if existing_position
        handle_existing_key(position: existing_position, context: context)
      else
        handle_new_key(state: state, context: context)
      end

      update_processor_state(
        state: state,
        new_position: existing_position || state.position + 1,
        indentation: context.indentation
      )
    end

    def calculate_indentation(level)
      "  " * (level + 1) # Add 1 to account for locale level
    end

    def find_existing_key(lookup_key)
      @file_contents.find_index { |line| line.start_with?(lookup_key) }
    end

    def handle_existing_key(position:, context:)
      # Key exists, but if it's the final key, update its value
      return unless context.final_key?

      formatted_value = format_value(context.translation.value)
      @file_contents[position] = "#{context.indentation}#{context.key}: #{formatted_value}\n"
    end

    def handle_new_key(state:, context:)
      new_position = state.position + 1

      if context.final_key?
        # Final key gets the value
        formatted_value = format_value(context.translation.value)
        @file_contents.insert(new_position, "#{context.indentation}#{context.key}: #{formatted_value}\n")
      else
        # Intermediate key just gets a colon and newline
        @file_contents.insert(new_position, "#{context.indentation}#{context.key}:\n")
      end
    end

    def update_processor_state(state:, new_position:, indentation:)
      # Update search boundaries for nested keys
      unless new_position + 1 > state.max_position
        next_key_offset = find_next_key_offset(
          start_position: new_position,
          max_position: state.max_position,
          indentation: indentation
        )
        new_max_position = calculate_new_max_position(new_position, next_key_offset, @file_contents.size)
        state.max_position = new_max_position if new_max_position
      end

      state.position = new_position
    end

    def find_next_key_offset(start_position:, max_position:, indentation:)
      @file_contents[(start_position + 1)..max_position].each_with_index do |line, idx|
        break idx if line =~ /^#{indentation}\w/ # next key at the same level
      end
    end

    def calculate_new_max_position(new_position, next_key_offset, file_size)
      if next_key_offset.is_a?(Integer)
        new_max = new_position + next_key_offset + 1
        new_max >= file_size ? file_size - 1 : new_max
      else
        file_size - 1
      end
    end

    def format_value(value)
      # Use YAML's built-in formatting to handle all edge cases properly
      YAML.dump(value).strip.sub(/^---\s*/, "")
    end

    # Helper class to manage processor state
    class ProcessorState
      attr_accessor :position, :max_position

      def initialize(position, max_position)
        @position = position
        @max_position = max_position
      end
    end

    # Encapsulates a translation entry with its key path and value
    class TranslationEntry
      attr_reader :key_path, :value, :keys

      def initialize(key_path:, value:)
        @key_path = key_path
        @value = value
        @keys = key_path.split(".")
      end
    end

    # Encapsulates context for processing a single key level
    class KeyContext
      attr_reader :key, :level, :translation, :indentation

      def initialize(key:, level:, translation:, indentation:)
        @key = key
        @level = level
        @translation = translation
        @indentation = indentation
      end

      def final_key?
        @level == @translation.keys.size - 1
      end
    end
  end
end
