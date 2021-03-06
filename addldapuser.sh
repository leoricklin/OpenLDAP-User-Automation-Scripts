#!/bin/sh
# filename: addldapuser.sh
CONFIG="/home/hdfs/ldap/config"
. $CONFIG
if [[ ( -z $1 ) || ( -z $2 ) ]]; then
  echo "$0 <gidNumber> <username>"
  exit 1
fi
LGID=$1
USERNAME=$2
LDIFNAME=$TMP/usr_$USERNAME.ldif
LUID=`echo $[ 20000 + $[ RANDOM % 9999 ]]`
PASSWORD=`$SLAPPASSWORD -h "{crypt}" -s $LUID`
(
cat <<add-user
dn: uid=$USERNAME,$LDAPUSERSUX
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
homeDirectory: /home/$USERNAME
loginShell: /bin/bash
gidNumber: $LGID
uidNumber: $LUID
uid: $USERNAME
cn: $USERNAME
sn: $USERNAME
userPassword: $PASSWORD
mail: $USERNAME@$DOMAIN
add-user
) > $LDIFNAME
$LDAPADDCMD -x -w $LDAPPASS -D "cn=root,$LDAPROOTSUX" -f $LDIFNAME
if [ $? -ne "0" ]; then
  echo "Failed"
  echo "Please review $LDIFNAME and add the account manually"
else
  echo "Successfully, gidNumber=$LGID, uidNumber=$LUID"
fi