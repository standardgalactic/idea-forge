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
