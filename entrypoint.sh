#!/bin/bash
trap 'exit' INT
render.py /etc/postfix/main.cf.jinja > /etc/postfix/main.cf
render.py /etc/postfix/master.cf.jinja > /etc/postfix/master.cf
render.py /etc/postfix/transport.jinja > /etc/postfix/transport
render.py /etc/postfix/virtual.jinja > /etc/postfix/virtual
postmap /etc/postfix/transport
postmap /etc/postfix/virtual
if [ -n "$SMTPD_TLS_DOMAIN" ]; then
  echo "Waiting for SSL certificates to appear.."
  for TLS_DOMAIN in ${SMTPD_TLS_DOMAIN} ${SUBMISSION_DOMAIN}; do
    while [ true ]; do
      if [ -r "/etc/postfix/tls/${TLS_DOMAIN}/fullchain.pem" ]; then
        break
      fi
      echo "/etc/postfix/tls/${TLS_DOMAIN}/fullchain.pem does not exist. waiting."
      sleep 2
    done
  done
fi
touch /etc/aliases
newaliases
/usr/sbin/postfix set-permissions
/usr/sbin/postfix check
/usr/local/bin/fake_syslog.py &
exec /usr/sbin/fork_proxy.sh /var/spool/postfix/pid/master.pid /usr/sbin/postfix start
