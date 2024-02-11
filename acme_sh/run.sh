#!/usr/bin/with-contenv bashio

ACCOUNT=$(bashio::config 'account')
SERVER=$(bashio::config 'server')
DOMAINS=$(bashio::config 'domains')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
DNS_PROVIDER=$(bashio::config 'dns.provider')
DNS_SLEEP=$(bashio::config 'dns.sleep')
DNS_ENVS=$(bashio::config 'dns.env')

for env in $DNS_ENVS; do
    export $env
done

DOMAIN_ARR=()
for domain in $DOMAINS; do
    DOMAIN_ARR+=(--domain "$domain")
done

SERVER_ARG="zerossl"
if [ -n "$SERVER" ]; then
    SERVER_ARG="--server $SERVER"
fi

if [ -z $DNS_SLEEP ]; then
    DNS_SLEEP=60
fi

/root/.acme.sh/acme.sh --register-account -m ${ACCOUNT} $SERVER_ARG

/root/.acme.sh/acme.sh --issue "${DOMAIN_ARR[@]}" \
--dns "$DNS_PROVIDER" \
--dnssleep $DNS_SLEEP \
$SERVER_ARG

/root/.acme.sh/acme.sh --install-cert "${DOMAIN_ARR[@]}" \
--fullchain-file "/ssl/${CERTFILE}" \
--key-file "/ssl/${KEYFILE}" \

tail -f /dev/null
