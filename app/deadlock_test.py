from multiprocessing import Process
from time import sleep
from threading import Thread

from sqlalchemy.orm import sessionmaker

import os
import sys

from db import transaction


def process1():
    with transaction() as tran:
        tran.execute('UPDATE users SET balance = balance + 10 WHERE id = 3;')
        sleep(2)
        tran.execute('UPDATE users SET balance = balance + 10 WHERE id = 1 RETURNING pg_sleep(2);')


def process2():
    with transaction() as tran:
        tran.execute('UPDATE users SET balance = balance + 10 WHERE id = 1;')
        sleep(2)
        tran.execute('UPDATE users SET balance = balance + 10 WHERE id = 3 RETURNING pg_sleep(2);')


if __name__ == '__main__':
    print("Starting transactions")
    p1 = Thread(target=process1)
    p2 = Thread(target=process2)
    p1.start()
    p2.start()
    sleep(4)
    print("Exit")