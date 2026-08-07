.PHONY: init lint test benchmark docs format release

init:
	cargo fetch

lint:
	cargo clippy --all-targets -- -D warnings

test:
	cargo test

benchmark:
	cargo bench || true

docs:
	cargo doc --no-deps && echo "Build static website"

format:
	cargo fmt --all

release:
	cargo package
