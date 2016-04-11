FROM ubuntu:wily
MAINTAINER Eugene Greendrake (eugene@greendrake.info)

# Needed to avoid root password promts on mysql installation
ENV DEBIAN_FRONTEND noninteractive

# To be able to run "top"
ENV TERM xterm

RUN \
  apt-get update -qq && \
  apt-get install -qq -y wget lsb-release && \
  wget https://repo.percona.com/apt/percona-release_0.1-3.$(lsb_release -sc)_all.deb && \
  dpkg -i percona-release_0.1-3.$(lsb_release -sc)_all.deb && \
  apt-get update -qq && \
  apt-get install -qq -y nano make rsync nginx telnet git net-tools php5-fpm php5-curl php5-mysqlnd supervisor sudo percona-server-server-5.6 php5-xdebug && \
  rm -f percona-release_0.1-3.$(lsb_release -sc)_all.deb && \
  apt-get autoremove && \
  apt-get clean && \
  sudo -u mysql mysql_install_db && \
  php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
  php composer-setup.php --install-dir=bin --filename=composer && \
  rm -f composer-setup.php && \
  wget https://phar.phpunit.de/phpunit.phar && \
  chmod +x phpunit.phar && \
  mv phpunit.phar /usr/local/bin/phpunit

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 80
CMD ["/usr/bin/supervisord"]