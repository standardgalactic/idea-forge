"""Simple parser utilities for lambda expressions."""


def normalize(expr: str) -> str:
    """Normalize whitespace around lambda syntax."""
    return " ".join(expr.replace("λ", "\\").split())
