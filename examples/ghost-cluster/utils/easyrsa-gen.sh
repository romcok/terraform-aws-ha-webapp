#!/bin/bash

# Source
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual

# Initialize a new PKI environment
easyrsa init-pki

# To build a new certificate authority (CA), run this command and follow the prompts.
easyrsa build-ca nopass

# Generate the server certificate and key.
easyrsa build-server-full server nopass

# Generate the client certificate and key.
# Make sure to save the client certificate and the client private key because you will need them when you configure the client.
easyrsa build-client-full client nopass

EASYRSA_PKI_PATH=/opt/homebrew/etc/pki
CERTIFICATE_PATH=vpn-certs

mkdir -p ${CERTIFICATE_PATH}
cp ${EASYRSA_PKI_PATH}/ca.crt ${CERTIFICATE_PATH}/
cp ${EASYRSA_PKI_PATH}/issued/server.crt ${CERTIFICATE_PATH}/
cp ${EASYRSA_PKI_PATH}/private/server.key ${CERTIFICATE_PATH}/
cp ${EASYRSA_PKI_PATH}/issued/client.crt ${CERTIFICATE_PATH}/
cp ${EASYRSA_PKI_PATH}/private/client.key ${CERTIFICATE_PATH}/

# Certificates should not be stored in the repository, so this is a better option
# aws acm import-certificate --certificate fileb://server.crt --private-key fileb://server.key --certificate-chain fileb://ca.crt
# aws acm import-certificate --certificate fileb://client1.domain.tld.crt --private-key fileb://client1.domain.tld.key --certificate-chain fileb://ca.crt