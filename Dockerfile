FROM pritunl/archlinux
MAINTAINER Julien BONACHERA <julien@bonachera.fr>
EXPOSE 25 465 587
ENTRYPOINT /sbin/entrypoint.sh
RUN pacman --noconfirm -S cyrus-sasl cyrus-sasl postfix python python-jinja
VOLUME ["/var/spool/postfix", "/var/lib/postfix"]
COPY smtp-sasl.conf /etc/sasl2/smtpd.conf
COPY fork_proxy.sh /usr/sbin/fork_proxy.sh
COPY conf.d/* /etc/postfix/
COPY render.py /usr/local/bin/render.py
COPY fake_syslog.ini /etc/fake_syslog.ini
COPY fake_syslog.py /usr/local/bin/fake_syslog.py
RUN chmod o-rwx -R /etc/postfix/
ADD entrypoint.sh /sbin/entrypoint.sh
