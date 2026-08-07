#!/usr/bin/env bash

starter_pack_math_machines() {
    local repo_path="$1" package="$2"

    mkdir -p "$repo_path/src/$package"/{turing,lambda,automata}

    cat > "$repo_path/src/$package/turing/tape.py" <<'EOF2'
"""Tape model for a minimal Turing machine."""

from dataclasses import dataclass, field


@dataclass
class Tape:
    """Infinite tape represented by sparse cells."""

    blank: str = "_"
    cells: dict[int, str] = field(default_factory=dict)
    head: int = 0

    def read(self) -> str:
        return self.cells.get(self.head, self.blank)

    def write(self, symbol: str) -> None:
        if symbol == self.blank:
            self.cells.pop(self.head, None)
        else:
            self.cells[self.head] = symbol

    def move(self, direction: str) -> None:
        if direction == "L":
            self.head -= 1
        elif direction == "R":
            self.head += 1
        elif direction != "N":
            raise ValueError(f"Invalid direction: {direction}")
EOF2

    cat > "$repo_path/src/$package/turing/transition.py" <<'EOF2'
"""Transition definitions for Turing machine execution."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Transition:
    """A single transition rule."""

    state: str
    symbol: str
    next_state: str
    write_symbol: str
    direction: str
EOF2

    cat > "$repo_path/src/$package/turing/machine.py" <<'EOF2'
"""Small deterministic single-tape Turing machine."""

from __future__ import annotations

from dataclasses import dataclass

from .tape import Tape


@dataclass
class Machine:
    """Executes a transition table over a tape."""

    start_state: str
    accept_state: str
    reject_state: str
    transitions: dict[tuple[str, str], tuple[str, str, str]]

    def run(self, tape: Tape, max_steps: int = 10_000) -> str:
        state = self.start_state
        steps = 0

        while state not in {self.accept_state, self.reject_state}:
            if steps >= max_steps:
                return self.reject_state

            symbol = tape.read()
            key = (state, symbol)
            if key not in self.transitions:
                return self.reject_state

            next_state, write_symbol, direction = self.transitions[key]
            tape.write(write_symbol)
            tape.move(direction)
            state = next_state
            steps += 1

        return state
EOF2

    cat > "$repo_path/src/$package/turing/examples.py" <<'EOF2'
"""Runnable Turing machine examples."""

from .machine import Machine
from .tape import Tape


def unary_increment() -> str:
    tape = Tape(cells={0: "1", 1: "1", 2: "_"})
    machine = Machine(
        start_state="scan",
        accept_state="accept",
        reject_state="reject",
        transitions={
            ("scan", "1"): ("scan", "1", "R"),
            ("scan", "_"): ("accept", "1", "N"),
        },
    )
    return machine.run(tape)
EOF2

    cat > "$repo_path/src/$package/lambda/parser.py" <<'EOF2'
"""Simple parser utilities for lambda expressions."""


def normalize(expr: str) -> str:
    """Normalize whitespace around lambda syntax."""
    return " ".join(expr.replace("λ", "\\").split())
EOF2

    cat > "$repo_path/src/$package/lambda/evaluator.py" <<'EOF2'
"""Tiny evaluator helpers for lambda calculus experiments."""


def beta_reduce_once(expr: str) -> str:
    """Perform one intentionally simple substitution step marker."""
    return expr.replace("(\\x.x)", "I", 1)
EOF2

    cat > "$repo_path/src/$package/lambda/reduction.py" <<'EOF2'
"""Reduction strategies for lambda expressions."""

from .evaluator import beta_reduce_once


def normalize(expr: str, steps: int = 16) -> str:
    """Iteratively apply one-step reduction until stable or step-limited."""
    current = expr
    for _ in range(steps):
        nxt = beta_reduce_once(current)
        if nxt == current:
            return current
        current = nxt
    return current
EOF2

    cat > "$repo_path/src/$package/automata/dfa.py" <<'EOF2'
"""Deterministic finite automaton implementation."""

from dataclasses import dataclass


@dataclass
class DFA:
    start: str
    accept: set[str]
    transitions: dict[tuple[str, str], str]

    def accepts(self, word: str) -> bool:
        state = self.start
        for symbol in word:
            state = self.transitions.get((state, symbol), "__dead__")
        return state in self.accept
EOF2

    cat > "$repo_path/src/$package/automata/nfa.py" <<'EOF2'
"""Nondeterministic finite automaton implementation."""

from dataclasses import dataclass


@dataclass
class NFA:
    start: str
    accept: set[str]
    transitions: dict[tuple[str, str], set[str]]

    def accepts(self, word: str) -> bool:
        states = {self.start}
        for symbol in word:
            nxt: set[str] = set()
            for state in states:
                nxt.update(self.transitions.get((state, symbol), set()))
            states = nxt
        return any(state in self.accept for state in states)
EOF2

    cat > "$repo_path/src/$package/automata/pda.py" <<'EOF2'
"""Pushdown automaton sketch with executable stack behavior."""

from dataclasses import dataclass, field


@dataclass
class PDA:
    stack: list[str] = field(default_factory=list)

    def push(self, symbol: str) -> None:
        self.stack.append(symbol)

    def pop(self) -> str | None:
        return self.stack.pop() if self.stack else None
EOF2
}

starter_pack_constraint_games() {
    local repo_path="$1" package="$2"
    mkdir -p "$repo_path/src/$package"/{common,sudoku,lights_out}

    cat > "$repo_path/src/$package/common/solver.py" <<'EOF2'
"""Common solver protocol for puzzle implementations."""

from typing import Protocol


class Solver(Protocol):
    """Solver interface shared across puzzle modules."""

    def solve(self) -> object:
        """Return a solved state representation."""
EOF2

    cat > "$repo_path/src/$package/sudoku/solver.py" <<'EOF2'
"""Backtracking Sudoku solver."""

from dataclasses import dataclass


@dataclass
class Sudoku:
    grid: list[list[int]]

    def _find_empty(self) -> tuple[int, int] | None:
        for r in range(9):
            for c in range(9):
                if self.grid[r][c] == 0:
                    return r, c
        return None

    def _valid(self, row: int, col: int, val: int) -> bool:
        if any(self.grid[row][c] == val for c in range(9)):
            return False
        if any(self.grid[r][col] == val for r in range(9)):
            return False
        br, bc = (row // 3) * 3, (col // 3) * 3
        for r in range(br, br + 3):
            for c in range(bc, bc + 3):
                if self.grid[r][c] == val:
                    return False
        return True

    def solve(self) -> list[list[int]]:
        pos = self._find_empty()
        if pos is None:
            return self.grid
        row, col = pos
        for candidate in range(1, 10):
            if self._valid(row, col, candidate):
                self.grid[row][col] = candidate
                if self._find_empty() is None or self.solve():
                    return self.grid
                self.grid[row][col] = 0
        return self.grid
EOF2

    cat > "$repo_path/src/$package/lights_out/solver.py" <<'EOF2'
"""Lights Out solver using greedy elimination over GF(2)."""

from dataclasses import dataclass


@dataclass
class LightsOut:
    board: list[list[int]]

    def _toggle(self, row: int, col: int) -> None:
        for r, c in ((row, col), (row - 1, col), (row + 1, col), (row, col - 1), (row, col + 1)):
            if 0 <= r < len(self.board) and 0 <= c < len(self.board[0]):
                self.board[r][c] ^= 1

    def solve(self) -> list[tuple[int, int]]:
        moves: list[tuple[int, int]] = []
        for row in range(1, len(self.board)):
            for col in range(len(self.board[0])):
                if self.board[row - 1][col] == 1:
                    self._toggle(row, col)
                    moves.append((row, col))
        return moves
EOF2
}

starter_pack_algorithm_zoo() {
    local repo_path="$1" package="$2"
    mkdir -p "$repo_path/src/$package"/{sorting,graphs,dp}

    cat > "$repo_path/src/$package/sorting/quick_sort.py" <<'EOF2'
"""Quick sort implementation for comparative experiments."""


def quick_sort(values: list[int]) -> list[int]:
    if len(values) <= 1:
        return values
    pivot = values[len(values) // 2]
    left = [v for v in values if v < pivot]
    middle = [v for v in values if v == pivot]
    right = [v for v in values if v > pivot]
    return quick_sort(left) + middle + quick_sort(right)
EOF2

    cat > "$repo_path/src/$package/graphs/traversal.py" <<'EOF2'
"""Graph traversal algorithms."""

from collections import deque


def bfs(graph: dict[str, list[str]], start: str) -> list[str]:
    seen = {start}
    queue = deque([start])
    order: list[str] = []
    while queue:
        node = queue.popleft()
        order.append(node)
        for nxt in graph.get(node, []):
            if nxt not in seen:
                seen.add(nxt)
                queue.append(nxt)
    return order
EOF2

    cat > "$repo_path/src/$package/graphs/shortest_paths.py" <<'EOF2'
"""Shortest path algorithms."""

import heapq


def dijkstra(graph: dict[str, list[tuple[str, int]]], start: str) -> dict[str, int]:
    dist: dict[str, int] = {start: 0}
    heap: list[tuple[int, str]] = [(0, start)]
    while heap:
        cost, node = heapq.heappop(heap)
        if cost > dist[node]:
            continue
        for nxt, weight in graph.get(node, []):
            new_cost = cost + weight
            if nxt not in dist or new_cost < dist[nxt]:
                dist[nxt] = new_cost
                heapq.heappush(heap, (new_cost, nxt))
    return dist
EOF2

    cat > "$repo_path/src/$package/dp/knapsack.py" <<'EOF2'
"""Dynamic programming examples."""


def knapsack_01(weights: list[int], values: list[int], capacity: int) -> int:
    dp = [0] * (capacity + 1)
    for i, w in enumerate(weights):
        v = values[i]
        for cap in range(capacity, w - 1, -1):
            dp[cap] = max(dp[cap], dp[cap - w] + v)
    return dp[capacity]
EOF2
}

apply_starter_pack() {
    local starter_pack="$1" repo_path="$2" package="$3"
    [ -z "$starter_pack" ] && return

    local fn="starter_pack_$(echo "$starter_pack" | tr '-' '_')"
    if ! declare -f "$fn" >/dev/null 2>&1; then
        err "Starter pack not found: $starter_pack"
        exit 1
    fi

    "$fn" "$repo_path" "$package"
}
