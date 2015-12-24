FROM phusion/passenger-full

ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf

RUN rm -f /etc/service/nginx/down

ENV APP_HOME /home/app

RUN ruby-switch --set ruby2.2

RUN rm /etc/nginx/sites-enabled/default


WORKDIR $APP_HOME

ADD . $APP_HOME

RUN su app -c ' bundle install \
                            --jobs=4 \
                            --path=/home/app/bundle \
                            --no-cache'
RUN su -c 'chown -R app:app $APP_HOME'
RUN su app -c 'RAILS_ENV=production bundle exec rake assets:precompile'
RUN su app -c 'RAILS_ENV=production bundle exec rake db:create'
RUN su app -c 'RAILS_ENV=production bundle exec rake db:migrate'

CMD ["/sbin/my_init"]
