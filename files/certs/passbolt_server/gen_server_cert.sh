#!/bin/bash

# passbolt_ansible

# Copyright (C) 2019  NeuroForge GmbH & Co.KG <https://neuroforge.de/>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

CA_DIR="$1"
BASEDIR="$2"
COMMON_NAME="$3"
PASSKEY="$4"

LOGGING_PREFIX="gen_cert.sh >> "

mkdir -p $BASEDIR

rm -f ${BASEDIR}/server.crt
rm -f ${BASEDIR}/server.csr
rm -f ${BASEDIR}/server.key

echo "$PASSKEY" > ${BASEDIR}/passkey.txt

# generate a key for our server certificate
echo 
echo "${LOGGING_PREFIX} Generating key for server certificate"
openssl genrsa -des3 -passout pass:${PASSKEY} -out ${BASEDIR}/server.pass.key 4096
openssl rsa -passin pass:${PASSKEY} -in ${BASEDIR}/server.pass.key -out ${BASEDIR}/server.key
rm ${BASEDIR}/server.pass.key
echo

# create a certificate request for our server. This includes a subject alternative name so either aios-localhost, localhost or postgres_ssl can be used to address it
echo
echo "${LOGGING_PREFIX} Creating server certificate"
openssl req -new -key ${BASEDIR}/server.key -out ${BASEDIR}/server.csr -subj "/emailAddress=test@your-domain.it/C=IT/ST=State/L=City/O=Organisation/OU=Organisation-dev/CN=${COMMON_NAME}" # -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:postgres_ssl,DNS:localhost,DNS:neuroforge-localhost")) 
echo "${LOGGING_PREFIX} Server certificate signing request (${BASEDIR}/server.csr) is:"
openssl req -verify -in ${BASEDIR}/server.csr -text -noout
echo

# use our CA certificate and key to create a signed version of the server certificate
echo 
echo "${LOGGING_PREFIX} Signing server certificate using our root CA certificate and key"
openssl x509 -req -sha512 -days 36500 -in ${BASEDIR}/server.csr -CA ${CA_DIR}/rootCA.crt -CAkey ${CA_DIR}/rootCA.key -CAcreateserial -out ${BASEDIR}/server.crt # -extensions SAN -extfile <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:postgres_ssl,DNS:localhost,DNS:aios-localhost")) 
chmod og-rwx ${BASEDIR}/server.key
echo "${LOGGING_PREFIX} Server certificate signed with our root CA certificate (${BASEDIR}/server.crt) is:"
openssl x509 -in ${BASEDIR}/server.crt -text -noout
echo

# done output the base64 encoded version of the root CA certificate which should be added to trust stores
echo
echo "${LOGGING_PREFIX} Use the following CA certificate variables:"
B64_CA_CERT=`cat ${CA_DIR}/rootCA.crt | base64`
echo "POSTGRES_SSL_CA_CERT=${B64_CA_CERT}"

cp ${CA_DIR}/rootCA.crt ${BASEDIR}/rootCA.crt

openssl x509 -outform der -in ${BASEDIR}/rootCA.crt -out ${BASEDIR}/rootCA.crt.der
openssl pkcs8 -topk8 -inform PEM -outform DER -in ${BASEDIR}/server.key -out ${BASEDIR}/server.key.pk8 -nocrypt
