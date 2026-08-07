.PHONY: init lint test benchmark docs format release

init:
	@echo "No init step configured"

lint:
	cd webapp && npm run lint

test:
	cd webapp && npm run test

benchmark:
	@echo "No benchmark step configured"

docs:
	latexmk -pdf papers/book/main.tex || true && echo "Document webapp in docs/" && echo "Build static website"

format:
	echo "Add formatter for webapp"

release:
	@echo "No release step configured"
