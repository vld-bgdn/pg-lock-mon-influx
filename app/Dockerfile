FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY db.py .
COPY deadlock_test.py .

CMD [ "python", "deadlock_test.py" ]