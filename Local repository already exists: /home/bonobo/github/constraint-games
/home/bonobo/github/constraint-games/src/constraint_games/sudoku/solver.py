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
