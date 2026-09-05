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
