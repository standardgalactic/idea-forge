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
