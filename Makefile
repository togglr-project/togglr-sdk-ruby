.PHONY: install test lint clean build generate update-client clean-generated

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

# Generate API client from OpenAPI spec
generate:
	openapi-generator-cli generate -i specs/sdk.yml -g ruby -o temp_generation --library faraday --additional-properties moduleName=TogglrClient,gemName=togglr-client
	@echo "Generated files in temp_generation/. Copy lib/togglr-client/ to lib/ to update the client."

# Update API client (generate and copy to lib/)
update-client: generate
	cp -r temp_generation/lib/togglr-client/* lib/togglr-client/
	@echo "API client updated successfully."

# Clean generated files
clean-generated:
	rm -rf temp_generation/
