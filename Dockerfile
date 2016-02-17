FROM docker.io/jbonachera/consul-template
MAINTAINER Julien BONACHERA <julien@bonachera.fr>
ONBUILD COPY consul-template.d/* /etc/consul-template/
ONBUILD COPY conf.d/* /etc/postfix/
ONBUILD RUN newaliases
ONBUILD RUN chmod o-rwx -R /etc/postfix/
VOLUME ["/var/spool/postfix", "/var/lib/postfix"]
EXPOSE 25 465 587
RUN dnf install -y cyrus-sasl cyrus-sasl-plain postfix postfix-mysql && \
    dnf clean all
COPY reload_postfix_if_running /usr/local/bin/reload_postfix_if_running
RUN chmod +x /usr/local/bin/reload_postfix_if_running
COPY postfix_policy_logger.py /usr/bin/postfix_policy_logger.py
COPY smtp-sasl.conf /etc/sasl2/smtpd.conf
COPY fork_proxy.sh /usr/sbin/fork_proxy.sh
COPY fake_syslog.ini /etc/fake_syslog.ini
COPY fake_syslog.py /usr/local/bin/fake_syslog.py
