"""Common solver protocol for puzzle implementations."""

from typing import Protocol


class Solver(Protocol):
    """Solver interface shared across puzzle modules."""

    def solve(self) -> object:
        """Return a solved state representation."""
