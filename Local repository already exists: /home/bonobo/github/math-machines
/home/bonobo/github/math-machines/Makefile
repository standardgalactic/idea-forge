.PHONY: init lint test benchmark docs format release

init:
	python -m pip install --upgrade pip && pip install -e ".[dev]"

lint:
	ruff check .

test:
	pytest

benchmark:
	python -m pytest benchmarks -q || true

docs:
	echo "Build docs with your chosen toolchain" && echo "Build static website"

format:
	ruff format .

release:
	python -m build || true
