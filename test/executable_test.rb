# frozen_string_literal: true

require "test_helper"

class TestExecutable < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir
    @original_dir = Dir.pwd
    Dir.chdir(@temp_dir)
    @exe_path = File.expand_path("../exe/i18n_add", __dir__)
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@temp_dir)
  end

  def test_executable_exists
    assert File.exist?(@exe_path), "Executable file should exist at #{@exe_path}"
    assert File.executable?(@exe_path), "File should be executable"
  end

  def test_executable_runs_help
    output = `ruby #{@exe_path} help 2>&1`
    assert_includes output, "Usage: i18n_add"
    assert_includes output, "--translation"
  end

  def test_executable_runs_with_args
    output = `ruby #{@exe_path} -t en.test=value 2>&1`
    assert_includes output, "✓"
    assert File.exist?("config/locales/en/main.en.yml")
  end

  def test_executable_shows_error_for_invalid_format
    output = `ruby #{@exe_path} -t invalid-format 2>&1`
    assert_includes output, "Invalid translation format"
  end
end
