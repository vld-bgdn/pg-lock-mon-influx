from contextlib import contextmanager
from traceback import extract_stack

from sqlalchemy import create_engine
from sqlalchemy.exc import OperationalError

import os
import sys

postgresql_url = os.getenv('POSTGRES_URI')
if postgresql_url is None:
    sys.exit('POSTGRES_URI must be specified')
engine = create_engine(postgresql_url)

def log_pg_stat_activity():
    '''Log, write or send through Sentry pg_stat_activity'''
    debug_conn = engine.connect()

    for process in debug_conn.execute('''
        SELECT pid, application_name, state, query FROM pg_stat_activity;
    ''').fetchall():
        print(process)

@contextmanager
def connection():
    conn = engine.connect()
    try:
        yield conn
    except OperationalError as ex:
        log_pg_stat_activity()
        raise

@contextmanager
def transaction(application_name=None):
    with connection() as conn:
        if application_name is None:
            caller = extract_stack()[-3]
            conn.execution_options(autocommit=True).execute("SET application_name = %s", '%s:%s' % (caller[0], caller[1]))
        with conn.begin() as trans:
            try:
                yield conn
            except OperationalError as ex:
                if 'deadlock detected' in ex.args[0]:
                    log_pg_stat_activity()
                    print(ex)
                    trans.rollback()
                else:
                    raise