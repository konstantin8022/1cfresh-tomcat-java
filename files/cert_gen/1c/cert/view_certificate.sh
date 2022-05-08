#!/bin/bash
# view certificate from the local directory, OS and JRE storages
# Common Name of the certificate given from the $1.data.sh file
# (CERTIFICATE_COMMON_NAME variable)

function s_message {
  echo
  echo "$1"
  echo "$1" | sed 's/./-/g'
}

if [ -z "$1" ] ; then
    s_message "No argument supplied"
    exit 1
fi
 
# script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#check if file $1.data.sh exists
if [ ! -f $DIR/$1.data.sh ]; then
  s_message "File \"$DIR/$1.data.sh\" not found."
  exit 2
fi

# get configuration variables
. $DIR/$1.data.sh

# check CERTIFICATE_COMMON_NAME variable 
if [[ -z "${CERTIFICATE_COMMON_NAME}" ]]; then
  echo Certificate Common Name not defined in file \"$1.data.sh\".
  exit
fi

# get certificate Common Name
CN=$CERTIFICATE_COMMON_NAME

# certificates directory
CDIR=/etc/pki-custom

s_message "View \"$CN\" certificate"

s_message "1. View \"$CN\" certificate from the \"$CDIR/$CN\" directory..."

# view certificate from local directory using openssl
openssl x509 -noout -certopt no_sigdump,no_pubkey -text -in $CDIR/$CN/$CN.crt

s_message "2. View \"$CN\" certificate from the OS storage..."

# view certificate from OS storage using openssl
openssl x509 -noout -certopt no_sigdump,no_pubkey -text -in /etc/ssl/certs/$CN.pem 

s_message "3. View \"$CN\" certificate from the JRE storage..."

# view certificate from JRE storage using keytool
JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
$JAVA_HOME/bin/keytool -list -v \
      -keystore $JAVA_HOME/jre/lib/security/cacerts  \
      -alias $CN -storepass changeit 
