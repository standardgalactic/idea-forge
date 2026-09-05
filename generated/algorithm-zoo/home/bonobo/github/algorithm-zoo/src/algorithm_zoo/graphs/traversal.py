"""Graph traversal algorithms."""

from collections import deque


def bfs(graph: dict[str, list[str]], start: str) -> list[str]:
    seen = {start}
    queue = deque([start])
    order: list[str] = []
    while queue:
        node = queue.popleft()
        order.append(node)
        for nxt in graph.get(node, []):
            if nxt not in seen:
                seen.add(nxt)
                queue.append(nxt)
    return order
