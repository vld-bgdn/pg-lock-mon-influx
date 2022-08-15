FROM python:3 as builder

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt

FROM python:3

WORKDIR /usr/src/app

COPY db.py .
COPY deadlock_test.py .

COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
COPY db.py .
COPY deadlock_test.py .

RUN pip install --no-cache /wheels/*

CMD [ "python", "-u", "deadlock_test.py" ]