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
