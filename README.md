# I18nAdd

A command-line tool for adding and updating internationalization (i18n) translations in YAML files efficiently. Supports nested keys, multiple locales, and custom file paths.

## Installation

Install the gem by executing:

    $ gem install i18n_add

Or add it to your application's Gemfile:

    gem 'i18n_add'

And then execute:

    $ bundle install

## Usage

Add or update translations using the command line:

```bash
# Add a single translation
i18n_add en.welcome.message="Welcome to our app"

# Add multiple translations
i18n_add -t en.welcome.message="Welcome" -t es.welcome.message="Bienvenido"

# Use custom file path template
i18n_add -f "locales/%{locale}.yml" en.greeting="Hello"
```

### Command Options

- `-t, --translation TRANSLATION`: Translation entry (can be used multiple times). Format: `locale.dot.separated.key=value`
- `-f, --file FILE`: Custom file path template. Use `%{locale}` as placeholder. Default: `config/locales/%{locale}/main.%{locale}.yml`
- `-h, --help`: Show help message

### Examples

```bash
# Basic usage
i18n_add en.users.welcome="Welcome user"

# Multiple translations
i18n_add -t en.buttons.save="Save" -t en.buttons.cancel="Cancel" -t es.buttons.save="Guardar"

# Custom file structure
i18n_add -f "app/locales/%{locale}.yml" en.nav.home="Home"

# Nested keys
i18n_add en.forms.user.name="Full Name" en.forms.user.email="Email Address"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/theExtraTerrestrial/i18n_add.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
