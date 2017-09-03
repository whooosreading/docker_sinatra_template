FROM phusion/passenger-ruby24:0.9.24

ENV HOME /root
CMD ["/sbin/my_init"]

RUN rm -f /etc/service/nginx/down

RUN rm /etc/nginx/sites-enabled/default

ADD docker/vhost.conf /etc/nginx/sites-enabled/app.conf

RUN mkdir /home/app/webapp

WORKDIR /tmp
COPY app/Gemfile /tmp/
COPY app/Gemfile.lock /tmp/
RUN bundle install

COPY app /home/app/webapp
RUN chown -R app:app /home/app

WORKDIR /home/app/webapp

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*