#!/usr/bin/env python3 -m

import sys
from loguru import logger

from timebandit._cli import main as CLI


if __name__ == "__main__":

    def time_test(n, x):
        for i in range(n):
            x = x ** 2

    sys.exit(CLI())
# from mypackage.myothermodule import add

# def main():
#     print(add('1', '1'))

# if __name__ == '__main__':
#     main()
