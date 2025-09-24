.PHONY: install test lint clean build

# Install dependencies
install:
	bundle install

# Run tests
test:
	bundle exec rspec

# Run linter
lint:
	bundle exec rubocop

# Run all checks
check: test lint

# Clean build artifacts
clean:
	rm -rf coverage/
	rm -rf pkg/
	rm -rf tmp/

# Build gem
build:
	bundle exec gem build togglr-sdk.gemspec

# Install gem locally
install-gem: build
	bundle exec gem install togglr-sdk-*.gem

# Run example
example:
	ruby examples/simple_example.rb

