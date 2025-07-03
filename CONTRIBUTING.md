# Contributing to I18nAdd

## Development Workflow

### Setting up for development

```bash
git clone https://github.com/theExtraTerrestrial/i18n_add.git
cd i18n_add
bundle install
```

### Making Changes

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and add tests if applicable

3. Run tests and linting:
   ```bash
   bundle exec rake
   ```

4. Commit using conventional commit format:
   ```bash
   git commit -m "feat: add new feature description"
   ```

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (version bumps, dependency updates)

Examples:
```
feat: add support for custom locale patterns
fix: handle empty YAML files correctly
docs: update README with new examples
chore: bump version to 0.2.0
```

### Versioning

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

#### Version Management

Use Rake tasks to bump versions:

```bash
# Check current version
bundle exec rake version:show

# Bump patch version (0.1.0 -> 0.1.1)
bundle exec rake version:patch

# Bump minor version (0.1.0 -> 0.2.0)
bundle exec rake version:minor

# Bump major version (0.1.0 -> 1.0.0)
bundle exec rake version:major
```

#### Release Process

1. Update `CHANGELOG.md` with new changes
2. Bump version: `bundle exec rake version:patch` (or minor/major)
3. Commit changes: `git add -A && git commit -m "chore: bump version to X.Y.Z"`
4. Tag the release: `git tag -a vX.Y.Z -m "Release version X.Y.Z"`
5. Push changes and tags: `git push && git push --tags`
6. Build and publish gem: `gem build i18n_add.gemspec && gem push i18n_add-X.Y.Z.gem`

### Pull Request Process

1. Ensure your branch is up to date with master:
   ```bash
   git checkout master
   git pull origin master
   git checkout your-feature-branch
   git rebase master
   ```

2. Push your branch and create a pull request

3. Ensure CI passes and request review

## Code Style

- Follow Ruby community standards
- Use RuboCop for linting: `bundle exec rubocop`
- Write clear, descriptive commit messages
- Add tests for new features
