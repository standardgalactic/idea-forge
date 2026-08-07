"""Tiny evaluator helpers for lambda calculus experiments."""


def beta_reduce_once(expr: str) -> str:
    """Perform one intentionally simple substitution step marker."""
    return expr.replace("(\\x.x)", "I", 1)
