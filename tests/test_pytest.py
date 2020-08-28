
import pytest


def _add(a: int, b: int) -> (int):
    return a + b


def test_add():
    for i in range(100):
        a = 3 * i
        b = 4 * i
        assert a + b == _add(a, b)


def test_true():
    """
    Test Doc: Line 1 ...
    """
    assert True
