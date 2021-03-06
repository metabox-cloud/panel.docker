FROM phusion/baseimage:0.11
MAINTAINER metaBox <contact@metabox.cloud>

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20
ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50
ENV SUPERVISOR_VERSION=4.2.0

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql && \
    groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1) && \
    groupmod -g ${BOOT2DOCKER_GID} staff
	

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN add-apt-repository -y ppa:ondrej/php && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install postfix sudo htop python3-setuptools wget git apache2 php-xdebug libapache2-mod-php pwgen php-apcu php-gd php-xml php-mbstring php-gettext zip unzip php-zip curl php-curl && \
  apt-get -y autoremove
  
  RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
sudo apt-key fingerprint 0EBFCD88 && \
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN echo "www-data   ALL = NOPASSWD: ALL" >> /etc/sudoers;
RUN apt-get install docker.io -y

# Install supervisor 4
RUN curl -L https://pypi.io/packages/source/s/supervisor/supervisor-${SUPERVISOR_VERSION}.tar.gz | tar xvz && \
  cd supervisor-${SUPERVISOR_VERSION}/ && \
  python3 setup.py install

RUN rm -rf /etc/apache2/ports.conf && \
	rm -rf /etc/apache2/apache2.conf && \
	rm -rf /etc/apache2/sites-available/000-default.conf
	
# Add image configuration and scripts
COPY /root /
RUN chmod 755 /*.sh

# config to enable .htaccess
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir -p /mb && rm -rf /var/www 

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
ENV PHP_VERSION 7.4

# Add volumes for the app and MySql
VOLUME  ["/mb" ]

EXPOSE 9999
HEALTHCHECK --timeout=10s CMD curl --silent --fail "http://127.0.0.1:9999/ping"
CMD ["/run.sh"]