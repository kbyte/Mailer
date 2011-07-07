#!/bin/bash

clear
echo "Mailer - Check and Create Mail Account System"
echo "======================================================"
echo "version 1.2 `date`"
echo " "
echo " "

u_acc=$1
a_acc=$2


if test -z $u_acc
then
 echo "Usage: mailer.sh <user> <alternate email account>"
 echo "Example: mailer.sh user_account alternate@mail.com" 
 exit 0
fi

if test -z $a_acc
then
 echo "Usage: mailer.sh <user> <alternate email account>"
 echo "Example: mailer.sh $u_acc alternate@mail.com"
 exit 0
fi

echo "checking $u_acc email account..."
echo " "

if grep -L ^$u_acc: /etc/passwd
 then
  echo "Mail user account exists, try another please..."
 else
  echo "Mail user account does not exist, you can continue and create user email account..."
  echo " "
  echo -n "Continue [s/n]: "
  read ans
  
  if test -z $ans
   then
    echo "Wrong answer..."
    echo "Ciao!"
    exit 0
  fi

  if [ $ans = "s" ] 
   then
    pasw=$(apg -n 1 -x 8)
    sudo useradd -m -s /bin/false -d /home/$u_acc $u_acc
    echo $u_acc:$pasw > pass_tmp
    sudo chpasswd < pass_tmp
    echo "User account: $u_acc"
    echo "Password: $pasw"
    echo " "
    echo " "
    sudo mkdir /home/$u_acc/Maildir
    echo "/home/$u_acc/Maildir has been created..."
    sudo chown -R $u_acc:$u_acc /home/$u_acc/Maildir
    sudo chmod -R 700 /home/$u_acc/Maildir
    echo "Permissions assigned to the account: $u_acc"
    echo " "
    echo " "
    echo "$u_acc@mail.server.com mail account has been created..."
    TXT="Usuario: $u_acc | Password: $pasw | Cuenta de correo: $u_acc@mail.server.com" 
    TXT1="$u_acc@mail.server.com" 
    sed -e '5,5s/^/'"$TXT"'/' -e '17,17s/^/'"$TXT1"'/' -e '18,18s/^/'"$a_acc"'/' notificacion.txt > $u_acc'_not'
    (cat $u_acc'_not'; uuencode manual.pdf manual.pdf) | mail -s "nueva cuenta de correo <Empresa>" $TXT1 sisadmin@mail.server.com $a_acc 
    LOG="Usuario: $u_acc | Password: $pasw | Fecha: `date` | Creada por: $USER"
    echo $LOG >> mailer.log
    sudo cp mailer.log /var/log/   
    echo " "
    rm pass_tmp
    rm $u_acc'_not'
   else
    echo "Ciao!"
    exit 0
  fi
fi
exit 0
