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
