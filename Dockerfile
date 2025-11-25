FROM python:3.11-slim 

# cadru de lucru 
# am un sistem de Linux unde am doar Py instalat

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# -r recursive 

COPY app/ .

# . este un loc default, unde ma aflu eu acum

RUN mkdir -p /app/logs

EXPOSE 5000

ENV FLASK_APP=main.py

CMD ["python", "main.py"]