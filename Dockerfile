FROM rluta/http2
MAINTAINER raphael.luta@gmail.com

ADD certs /certs
ADD bin/ /usr/local/bin/
ADD conf/ /usr/local/etc/
ADD www/ /var/www/

WORKDIR /var/www
VOLUME ["/var/www","/certs"]

CMD h2o -c /usr/local/etc/h2o.conf

EXPOSE 80 443 8080 8443 8444
