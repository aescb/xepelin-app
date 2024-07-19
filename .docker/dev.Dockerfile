FROM ruby:3.3.0

ENV TZ=America/Santiago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

CMD ["/app/.docker/dev.init.sh"]
