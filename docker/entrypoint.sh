#!/bin/bash

DKIM_TOKEN=`cat *.txt \
  | tr '\n' ' ' \
  | sed -e 's/^.*p=\(.*\)".*"\(.*\)" ).*$/v=DKIM1; h=sha256; k=rsa; s=email; p=\1\2/g'`

service syslog-ng start > /dev/null
service postfix start > /dev/null
service dovecot start > /dev/null
service opendkim start > /dev/null
service spamassassin start > /dev/null

echo '=========================================================='
echo ' MAIL SERVER - INSTRUCTIONS'
echo '=========================================================='
echo ' 1) Insert these 6 records into your DNS zone :'
echo '----------------------------------------------------------'
echo "  - A record for domain \"mail.${DOMAIN_FULL}\" with value \"X.X.X.X\" (your server public IP)"
echo "  - MX record for domain \"${DOMAIN_FULL}\" with value \"1 mail.${DOMAIN_FULL}\""
echo "  - TXT record for domain \"${DOMAIN_FULL}\" with value \"v=spf1 mx -all\""
echo "  - TXT record for domain \"_dmarc.${DOMAIN_FULL}\" with value \"v=DMARC1;p=quarantine;sp=quarantine;adkim=r;aspf=r\""
echo "  - TXT record for domain \"_adsp._domainkey.${DOMAIN_FULL}\" with value \"dkim=all\""
echo "  - TXT record for domain \"mail._domainkey.${DOMAIN_FULL}\" with value \"${DKIM_TOKEN}\""
echo '----------------------------------------------------------'
echo ' 2) Redirect the ports 25 and 143 to your host machine'
echo '    (only if you are behind a NAT)'
echo '----------------------------------------------------------'
echo ' 3) Enjoy your privacy :)'
echo '=========================================================='

tail -F -n +1 /var/log/mail.log

