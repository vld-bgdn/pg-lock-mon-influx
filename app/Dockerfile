FROM python:3-slim as builder

WORKDIR /usr/src/app

RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-server-dev-all gcc python3-dev musl-dev

COPY requirements.txt ./
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt

FROM python:3-slim

WORKDIR /usr/src/app

COPY db.py .
COPY deadlock_test.py .

COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
COPY db.py .
COPY deadlock_test.py .

RUN pip install --no-cache /wheels/*
RUN pip install psycopg2-binary

CMD [ "python", "-u", "deadlock_test.py" ]