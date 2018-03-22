FROM debian:latest
LABEL maintainer="clement.douin@gmail.com"

ARG DOMAIN_FULL
ARG USERNAME
ARG PASSWORD
ARG COUNTRY
ARG STATE
ARG CITY
ARG COMPANY

WORKDIR /tmp

ENV DEBIAN_FRONTEND="noninteractive"

RUN useradd --create-home --shell /bin/false ${USERNAME}
RUN echo "${USERNAME}:${PASSWORD}" | chpasswd

RUN echo "postfix postfix/main_mailer_type string Internet site" | debconf-set-selections
RUN echo "postfix postfix/mailname string mail.${DOMAIN_FULL}" | debconf-set-selections

RUN \
  apt-get update && \
  apt-get install -y \
    syslog-ng \
    procps \
    postfix \
    dovecot-core \
    dovecot-imapd \
    opendkim \
    opendkim-tools \
    postfix-policyd-spf-python \
    postfix-pcre \
    spamassassin \
    spamc && \
  rm -rf /var/lib/apt/lists/*

RUN \
  usermod -a -G ssl-cert postfix && \
  usermod -a -G ssl-cert dovecot && \
  usermod -a -G ssl-cert mail && \
  usermod -a -G opendkim postfix

RUN openssl req \
  -new \
  -newkey rsa:4096 \
  -days 365 \
  -nodes \
  -x509 \
  -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${COMPANY}/CN=mail.${DOMAIN_FULL}" \
  -keyout /etc/ssl/private/mailkey.pem \
  -out /etc/ssl/certs/mailcert.pem

RUN \
  chmod 750 /etc/ssl/private && \
  chmod 640 /etc/ssl/private/mailkey.pem && \
  chmod 644 /etc/ssl/certs/mailcert.pem && \
  chown root:ssl-cert /etc/ssl/private && \
  chown root:ssl-cert /etc/ssl/private/mailkey.pem

RUN opendkim-genkey \
  -b 2048 \
  -h rsa-sha256 \
  -r \
  -s mail \
  -d "${DOMAIN_FULL}" \
  -v

RUN export DOMAIN=`echo ${DOMAIN_FULL} | awk -F'.' '{print $1}'`
RUN \
  mkdir -p /etc/opendkim/keys && \
  mkdir -p /var/spool/postfix/var/run/opendkim && \
  mv "mail.private" "/etc/opendkim/keys/${DOMAIN}.private" && \
  chown -R opendkim:opendkim /etc/opendkim && \
  chown opendkim:opendkim /var/spool/postfix/var/run/opendkim && \
  chmod go-rw /etc/opendkim/keys

COPY config/postfix/* /etc/postfix/
COPY config/dovecot/* /etc/dovecot/conf.d/
COPY config/opendkim/key.table /etc/opendkim/
COPY config/opendkim/signing.table /etc/opendkim/
COPY config/opendkim/trusted.hosts /etc/opendkim/
COPY config/opendkim/opendkim.conf /etc/
COPY config/opendkim/opendkim /etc/default/
COPY config/spamassassin/local.cf /etc/spamassassin/
COPY config/spamassassin/spamassassin /etc/default/

RUN \
  sed -i -e "s/example\.com/${DOMAIN_FULL}/g" /etc/postfix/main.cf && \
  sed -i -e "s/example/${DOMAIN}/g" /etc/opendkim/key.table && \
  sed -i -e "s/example\.com/${DOMAIN_FULL}/g" /etc/opendkim/key.table && \
  sed -i -e "s/example/${DOMAIN}/g" /etc/opendkim/signing.table && \
  sed -i -e "s/example\.com/${DOMAIN_FULL}/g" /etc/opendkim/signing.table && \
  sed -i -e "s/example\.com/${DOMAIN_FULL}/g" /etc/opendkim/trusted.hosts

COPY entrypoint.sh .

ENTRYPOINT ["bash"]
CMD ["entrypoint.sh"]

