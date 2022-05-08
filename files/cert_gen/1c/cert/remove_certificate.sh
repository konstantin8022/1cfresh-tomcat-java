#!/bin/bash
# Remove certificate with Common Name defined in the $1.data.sh file

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
  echo Certificate Common Name not defined in file \"$DIR/$1.data.sh\".
  exit
fi

# get certificate Common Name
CN=$CERTIFICATE_COMMON_NAME

# certificates directory
CDIR=/etc/pki-custom

s_message "Remove \"${CN}\" certificate"

s_message "1. Remove the \"$CDIR/$CN\" directory..."

# delete certificate directory
rm -rf $CDIR/$CN

s_message "2. Remove \"${CN}\" certificate from the OS storage..."

# remove certificate from OS storage using update-ca-certificates
rm -f /usr/local/share/ca-certificates/$CN.crt
update-ca-certificates

s_message "3. Remove \"${CN}\" certificate from the JRE storage..."
JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
$JAVA_HOME/bin/keytool -delete -noprompt \
      -keystore $JAVA_HOME/jre/lib/security/cacerts  \
      -alias $CN -storepass changeit
