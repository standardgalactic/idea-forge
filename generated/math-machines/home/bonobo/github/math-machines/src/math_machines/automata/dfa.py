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
