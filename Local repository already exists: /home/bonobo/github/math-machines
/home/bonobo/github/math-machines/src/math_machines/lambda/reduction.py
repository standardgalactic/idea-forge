"""Reduction strategies for lambda expressions."""

from .evaluator import beta_reduce_once


def normalize(expr: str, steps: int = 16) -> str:
    """Iteratively apply one-step reduction until stable or step-limited."""
    current = expr
    for _ in range(steps):
        nxt = beta_reduce_once(current)
        if nxt == current:
            return current
        current = nxt
    return current
