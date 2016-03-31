#!/bin/bash

mode=${1:-help}
name=${2:-aptiwan.com}
shift
shift

if [ ! -e "/certs/$name.pem" ]
then
    echo "Generating new cert for $name"
    openssl req -new -x509 -subj /CN=$name -newkey rsa:1024 -days 365 -nodes -keyout /certs/$name.pem -out /certs/$name.crt
fi

case "$mode" in
proxy)
  cat <<EOF >/var/www/secure.pac
function FindProxyForURL(url, host) {
  return "HTTPS $name:3000";
}
EOF
  squid3
  h2o -m daemon -c /usr/local/etc/h2o-simple.conf
  nghttpx -s -b 127.0.0.1,3128 $* /certs/$name.pem /certs/$name.crt
  ;;
reverse)
  nghttpx -b $name,80 $* /certs/$name.pem /certs/$name.crt
  ;;
local)
  service apache2 start
  nghttpx $* /certs/$name.pem /certs/$name.crt
  ;;
*)
  echo "run.sh <proxy|reverse|local> certname"
  ;; 
esac
