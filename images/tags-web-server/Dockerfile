FROM ubuntu:20.04

RUN apt update -y && apt install python3-pip -y
RUN pip3 install poetry

ADD poetry.lock .
ADD pyproject.toml .
RUN poetry export --without-hashes -f requirements.txt -o requirements.txt

RUN pip3 install -r requirements.txt

COPY tags-file-generator.py ./

COPY tags-web-server.sh /
RUN chmod +x /tags-web-server.sh

RUN rm -rf /var/www/html/*

EXPOSE 80

CMD ["bash", "/tags-web-server.sh"]
