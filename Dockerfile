FROM fedora:latest
MAINTAINER Julien BONACHERA <julien@bonachera.fr>
EXPOSE 25 465 587
ENTRYPOINT /sbin/entrypoint.sh
RUN dnf install -y cyrus-sasl cyrus-sasl-plain postfix && \
    dnf clean all
VOLUME ["/var/spool/postfix", "/var/lib/postfix"]
COPY smtp-sasl.conf /etc/sasl2/smtpd.conf
COPY fork_proxy.sh /usr/sbin/fork_proxy.sh
COPY conf.d/* /etc/postfix/
COPY fake_syslog.ini /etc/fake_syslog.ini
COPY fake_syslog.py /usr/local/bin/fake_syslog.py
RUN newaliases
RUN chmod o-rwx -R /etc/postfix/
ADD entrypoint.sh /sbin/entrypoint.sh
