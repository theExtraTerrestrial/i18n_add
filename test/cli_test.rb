# frozen_string_literal: true

require "test_helper"

class TestCLI < Minitest::Test
  def setup
    @original_stdout = $stdout
    @stdout_capture = StringIO.new
    $stdout = @stdout_capture
  end

  def teardown
    $stdout = @original_stdout
  end

  def captured_output
    @stdout_capture.string
  end

  def test_help_command
    I18nAdd::CLI.run(["help"])
    assert_includes captured_output, "Usage: i18n_add"
    assert_includes captured_output, "--translation"
    assert_includes captured_output, "--file"
  end

  def test_help_flag
    I18nAdd::CLI.run(["-h"])
    assert_includes captured_output, "Usage: i18n_add"
  end

  def test_help_flag_long
    I18nAdd::CLI.run(["--help"])
    assert_includes captured_output, "Usage: i18n_add"
  end

  def test_empty_args_shows_help
    I18nAdd::CLI.run([])
    assert_includes captured_output, "Usage: i18n_add"
  end

  def test_no_translations_provided_error
    # The error message goes to stdout, not stderr, and exit(1) is called
    assert_raises SystemExit do
      I18nAdd::CLI.run(["-f", "test.yml"])
    end
    assert_includes captured_output, "No translations provided"
  end

  def test_invalid_translation_format
    # We need to temporarily change to a temp directory for this test
    Dir.mktmpdir do |temp_dir|
      Dir.chdir(temp_dir) do
        assert_raises SystemExit do
          I18nAdd::CLI.run(["-t", "invalid-format"])
        end
        assert_includes captured_output, "Invalid translation format"
      end
    end
  end

  def test_single_positional_translation
    Dir.mktmpdir do |temp_dir|
      Dir.chdir(temp_dir) do
        I18nAdd::CLI.run(["en.test.key=value"])
        # Should process without errors and show success message
        assert_includes captured_output, "✓"
      end
    end
  end

  def test_multiple_translations_with_flag
    Dir.mktmpdir do |temp_dir|
      Dir.chdir(temp_dir) do
        I18nAdd::CLI.run(["-t", "en.test.key1=value1", "-t", "en.test.key2=value2"])
        # Should process both translations
        assert_includes captured_output, "test.key1"
        assert_includes captured_output, "test.key2"
      end
    end
  end

  def test_custom_file_template
    Dir.mktmpdir do |temp_dir|
      Dir.chdir(temp_dir) do
        I18nAdd::CLI.run(["-f", "custom/%<locale>s.yml", "-t", "en.test.key=value"])
        assert File.exist?("custom/en.yml")
      end
    end
  end

  def test_default_file_path
    Dir.mktmpdir do |temp_dir|
      Dir.chdir(temp_dir) do
        I18nAdd::CLI.run(["-t", "en.test.key=value"])
        assert File.exist?("config/locales/en/main.en.yml")
      end
    end
  end

  def test_multiple_locales
    Dir.mktmpdir do |temp_dir|
      Dir.chdir(temp_dir) do
        I18nAdd::CLI.run(["-t", "en.test.key=English", "-t", "es.test.key=Español"])
        assert File.exist?("config/locales/en/main.en.yml")
        assert File.exist?("config/locales/es/main.es.yml")

        en_content = File.read("config/locales/en/main.en.yml")
        es_content = File.read("config/locales/es/main.es.yml")

        assert_includes en_content, "English"
        assert_includes es_content, "Español"
      end
    end
  end
end
