"""Pushdown automaton sketch with executable stack behavior."""

from dataclasses import dataclass, field


@dataclass
class PDA:
    stack: list[str] = field(default_factory=list)

    def push(self, symbol: str) -> None:
        self.stack.append(symbol)

    def pop(self) -> str | None:
        return self.stack.pop() if self.stack else None
