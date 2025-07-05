# frozen_string_literal: true

require "test_helper"

class TestI18nAdd < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::I18nAdd::VERSION
  end

  def test_version_is_string
    assert_instance_of String, ::I18nAdd::VERSION
  end

  def test_version_format
    assert_match(/\A\d+\.\d+\.\d+\z/, ::I18nAdd::VERSION)
  end

  def test_error_class_exists
    assert_equal StandardError, ::I18nAdd::Error.superclass
  end
end
