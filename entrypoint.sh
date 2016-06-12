#!/bin/bash
trap 'exit' INT
sed -i "s/@@RMILTER_HOST@@/${RMILTER_HOST}/g" /etc/postfix/main.cf
sed -i "s/@@SMTPD_DOMAINS@@/${SMTPD_DOMAINS}/g" /etc/postfix/main.cf
for DOMAIN in $(echo ${SMTPD_DOMAINS}| tr ',' ' '); do
    echo "${DOMAIN} lmtp:${RELAY_HOST}" >> /etc/postfix/transport
done
postmap /etc/postfix/transport
if [ -n "$SMTPD_TLS_DOMAIN" ]; then
  sed -i "s/@@SMTPD_TLS_DOMAIN@@/${SMTPD_TLS_DOMAIN}/g" /etc/postfix/main.cf
  sed -i "s/@@SUBMISSION_DOMAIN@@/${SUBMISSION_DOMAIN}/g" /etc/postfix/master.cf
  
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
/usr/local/bin/fake_syslog.py &
exec /usr/sbin/fork_proxy.sh /var/spool/postfix/pid/master.pid /usr/sbin/postfix start
