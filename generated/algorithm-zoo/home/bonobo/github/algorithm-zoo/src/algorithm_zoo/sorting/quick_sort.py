"""Quick sort implementation for comparative experiments."""


def quick_sort(values: list[int]) -> list[int]:
    if len(values) <= 1:
        return values
    pivot = values[len(values) // 2]
    left = [v for v in values if v < pivot]
    middle = [v for v in values if v == pivot]
    right = [v for v in values if v > pivot]
    return quick_sort(left) + middle + quick_sort(right)
