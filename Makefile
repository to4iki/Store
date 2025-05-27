.PHONY: test
test:
	swift test --package-path Store --parallel

.PHONY: format
format:
	@swift format \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		./Store/ \
		./Example.swiftpm/
