.PHONY: test
test:
	swift test --parallel

.PHONY: coverage
coverage:
	swift test --enable-code-coverage
	./scripts/export-lcov.sh

.PHONY: format
format:
	@swift format \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		./Store/ \
		./Example.swiftpm/
