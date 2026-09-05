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
