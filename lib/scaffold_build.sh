#!/usr/bin/env bash

write_makefile() {
    local path="$1"

    cat > "$path/Makefile" <<EOF2
.PHONY: init lint test benchmark docs format release

init:
	${MAKE_TARGETS[init]}

lint:
	${MAKE_TARGETS[lint]}

test:
	${MAKE_TARGETS[test]}

benchmark:
	${MAKE_TARGETS[benchmark]}

docs:
	${MAKE_TARGETS[docs]}

format:
	${MAKE_TARGETS[format]}

release:
	${MAKE_TARGETS[release]}
EOF2
}
