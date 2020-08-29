
import timebandit


def _add(a: int, b: int) -> (int):
    return a + b


def test_timebandit_basics():

    assert isinstance(timebandit.timeit(func=list), float)


def test_timebandit_repeat():
    assert isinstance(timebandit.repeat(func=set), list)


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
