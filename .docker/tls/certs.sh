#!/bin/sh
#
# From https://medium.com/@rajanmaharjan/secure-your-mongodb-connections-ssl-tls-92e2addb3c89

set -eu -o pipefail

# if the first argument is not an option so exec the command
if [ "${1#-}" = "$1" ]; then
	exec "$@"
fi

# ======================================================================================================================
# Global variables
# ======================================================================================================================

COLOR_RESET='\033[0m'

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'

COLOR_RED_BOLD='\033[1;31m'
COLOR_GREEN_BOLD='\033[1;32m'
COLOR_YELLOW_BOLD='\033[1;33m'
COLOR_BLUE_BOLD='\033[1;34m'

BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'

CERTS_DIR=/certs

# ======================================================================================================================
# Help
# ======================================================================================================================
Help()
{
  echo "Script to generate TLS certificate based on minica library."
  echo "The certificate will be generated for a wildcard, you don't need to specify the sub domain."
  echo
  echo "Syntax: docker-certs [-d|h|V]"
  echo "options:"
  echo "d     The domain."
  echo "h     Print this Help."
  echo "V     Print software version and exit."
  echo
  echo -e "${COLOR_GREEN}Example : docker run --rm -d domain.one -d domain.two${COLOR_RESET}"
  echo
}

Cert()
{
  domain="$1"

  if [ -d "${CERTS_DIR}" ]; then
    GENERATION_DIRNAME="${CERTS_DIR}/_.$(echo "$domain" | cut -d, -f1)"

    if [ ! -d "${GENERATION_DIRNAME}" ]; then
      echo ":: Checking Requirements ::"
      command -v go >/dev/null 2>&1 || echo "Golang is required"
      command -v minica >/dev/null 2>&1 || go get github.com/jsha/minica >/dev/null

      echo ":: Generating Certificates for the following domains: *.$domain ::"
      mkdir -p "${GENERATION_DIRNAME}"
      cd "${CERTS_DIR}"
      minica --ca-cert minica.pem --ca-key=minica-key.pem --domains="*.$domain"

      cat "${GENERATION_DIRNAME}/key.pem" "${GENERATION_DIRNAME}/cert.pem" > "${GENERATION_DIRNAME}/ck.pem"

      echo ":: Certificates Generated in the directory ${GENERATION_DIRNAME} ::"
    fi
  fi
}

while getopts ":hVd:" option; do
  case $option in
    h)
      Help
      exit 0;;
    V)
      echo 'v1.0.0'
      exit 0;;
    d)
      Cert "$OPTARG";;
    \?) # Invalid option
      echo "Error: Invalid option"
  esac
done
