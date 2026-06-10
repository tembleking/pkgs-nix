#!/usr/bin/env bash

set -eu
umask 077

autofirma_dir="${HOME}/.afirma/Autofirma"
autofirma_ca="${autofirma_dir}/AutoFirma_ROOT.cer"
autofirma_pfx="${autofirma_dir}/autofirma.pfx"
cert_days=3650
cert_cn="AutoFirma ROOT"
nssdb_dir="${HOME}/.pki/nssdb"
new_firefox_config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/mozilla/firefox"
legacy_firefox_config_dir="${HOME}/.mozilla/firefox"
temp_dir=

cleanup() {
  if [[ -n "${temp_dir}" ]]; then
    @rm@ -rf "${temp_dir}"
  fi
}
trap cleanup EXIT

make_ca_config() {
  @cat@ > "${temp_dir}/openssl.cnf" <<EOF
[ ca ]
default_ca=CA_autofirma
[ CA_autofirma ]
dir=${temp_dir}
new_certs_dir=\$dir
database=\$dir/index.txt
serial=\$dir/serial
crlnumber=\$dir/crlnumber
default_days=${cert_days}
default_crl_days=30
default_md=sha256
preserve=no
x509_extensions=usr_cert
email_in_dn=no
copy_extensions=copy
[ policy_ca ]
countryName=optional
stateOrProvinceName=optional
localityName=optional
organizationName=optional
organizationalUnitName=optional
commonName=supplied
emailAddress=optional
[ req ]
default_bits=4096
x509_extensions=v3_ca
distinguished_name=req_distinguished_name
[ req_distinguished_name ]
commonName_default=${cert_cn}
[ usr_cert ]
basicConstraints=CA:FALSE
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
subjectAltName=IP:127.0.0.1,DNS:localhost
[ v3_ca ]
basicConstraints=critical,CA:TRUE
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
keyUsage=cRLSign,digitalSignature,keyCertSign,keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth,anyExtendedKeyUsage
EOF

  @touch@ "${temp_dir}/index.txt"
  @printf@ '01\n' > "${temp_dir}/crlnumber"
}

generate_certificates() {
  local password_file

  @mkdir@ -p "${autofirma_dir}"
  @chmod@ 700 "${autofirma_dir}"
  temp_dir="$(@mktemp@ -d)"
  password_file="${temp_dir}/randomkey.txt"
  make_ca_config

  @openssl@ rand -base64 48 > "${password_file}"

  @openssl@ req -config "${temp_dir}/openssl.cnf" \
    -quiet \
    -new \
    -passout "file:${password_file}" \
    -keyout "${temp_dir}/autofirma.key" \
    -subj "/CN=${cert_cn}" \
    -out "${temp_dir}/autofirma.csr"

  @openssl@ ca -config "${temp_dir}/openssl.cnf" \
    -quiet \
    -batch \
    -create_serial \
    -notext \
    -selfsign \
    -extensions v3_ca \
    -policy policy_ca \
    -out "${temp_dir}/AutoFirma_ROOT.cer" \
    -days "${cert_days}" \
    -passin "file:${password_file}" \
    -keyfile "${temp_dir}/autofirma.key" \
    -infiles "${temp_dir}/autofirma.csr"

  @openssl@ req -config "${temp_dir}/openssl.cnf" \
    -quiet \
    -new \
    -passout "file:${password_file}" \
    -keyout "${temp_dir}/localhost.key" \
    -subj "/CN=127.0.0.1" \
    -out "${temp_dir}/localhost.csr"

  @openssl@ ca -config "${temp_dir}/openssl.cnf" \
    -quiet \
    -batch \
    -notext \
    -extensions usr_cert \
    -policy policy_ca \
    -out "${temp_dir}/localhost.cer" \
    -cert "${temp_dir}/AutoFirma_ROOT.cer" \
    -keyfile "${temp_dir}/autofirma.key" \
    -passin "file:${password_file}" \
    -infiles "${temp_dir}/localhost.csr"

  @openssl@ pkcs12 -export \
    -passin "file:${password_file}" \
    -inkey "${temp_dir}/localhost.key" \
    -certfile "${temp_dir}/AutoFirma_ROOT.cer" \
    -in "${temp_dir}/localhost.cer" \
    -name socketautofirma \
    -passout pass:654321 \
    -out "${temp_dir}/autofirma.pfx"

  @install@ -m 600 "${temp_dir}/autofirma.pfx" "${autofirma_pfx}"
  @install@ -m 644 "${temp_dir}/AutoFirma_ROOT.cer" "${autofirma_ca}"
}

trust_ca_in_database() {
  local database="$1"

  @certutil@ -d "${database}" -D -n "${cert_cn}" >/dev/null 2>&1 || true
  if ! @certutil@ -d "${database}" -A -i "${autofirma_ca}" \
    -n "${cert_cn}" -t 'C,,'; then
    @printf@ 'warning: could not trust the AutoFirma CA in %s\n' "${database}" >&2
  fi
}

trust_ca_in_firefox() {
  local config_dir="$1"
  local profile_path

  [[ -r "${config_dir}/profiles.ini" ]] || return 0

  while IFS= read -r profile_path; do
    profile_path="${profile_path#Path=}"
    [[ "${profile_path}" = /* ]] || profile_path="${config_dir}/${profile_path}"
    [[ -d "${profile_path}" ]] || continue

    if [[ -f "${profile_path}/cert9.db" ]]; then
      trust_ca_in_database "sql:${profile_path}"
    else
      trust_ca_in_database "${profile_path}"
    fi
  done < <(@grep@ '^Path=' "${config_dir}/profiles.ini")
}

if [[ ! -r "${autofirma_ca}" || ! -r "${autofirma_pfx}" ]]; then
  generate_certificates
fi

if [[ -d "${nssdb_dir}" ]]; then
  trust_ca_in_database "sql:${nssdb_dir}"
fi

trust_ca_in_firefox "${new_firefox_config_dir}"
trust_ca_in_firefox "${legacy_firefox_config_dir}"

exec @java@ \
  -Djdk.tls.maxHandshakeMessageSize=65536 \
  -jar @autofirmaJar@ "$@"
