#!/bin/bash
# mailer.sh 

############################################################################
#                                                                          #
# Script para automatizar la creacion de cuentas de correo Empresa         #
#								           #
# Dependencias:                                                            #
# Ubuntu GNU/Linux                                                         #
# 								           #
# apg      <- generador de contraseñas (apt-get install apg)               #
# uuencode <- codifica el pdf y lo adjunta (apt-get install sharutils)     #
# mail     <- envia el correo desde terminal (apt-get install mailutils)   #
# ------------------------------------------------------------------------ #
#									   #
# Parametros:                                                              #
#          	 							   #
# u_acc    <- corresponde a la cuenta del usuario                          #
# a_acc    <- corresponde a la cuenta de correo alterno del usuario        #
# ------------------------------------------------------------------------ #
#	         						           #
# Archivos: 								   #
#                                                                          #
# notificacion.txt <- plantilla de notificacion                            #
#                     editar según corresponda en cada caso.               #
# manual.pdf      <- manual pdf con instrucciones de configuracion y uso   #
#                     crear nuevo archivo según corresponda                #
# u_acc_not        <- notificacion personalizada para el usuario           #
# ------------------------------------------------------------------------ #
#                                                                          #
# Logs:                                                                    #
#                                                                          #
# mailer.log  <- archivo de texto con informacion historica de mailer.sh   #
# newmail.log <- archivo con informacion de la ultima cuenta creada        #
#                                                                          #
############################################################################

### Se limpia la pantalla y se presenta el script

clear
echo "Mailer - Check and Create Mail Account System"
echo "============================================="
echo "version 1.0 `date`"
echo " "
echo " "

### Se le pasa el primer parametro (cuenta del usuario) que recibe el script a la variable u_acc
u_acc=$1 

### Se le pasa el segundo parametro (cuenta de correo alterno del usuario) que recibe el script a la variable a_acc
a_acc=$2

### Se valida el primer parametro, se verifica que no sea nulo y se explica el uso correcto del script
if test -z $u_acc
then
 echo "Usage: mailer.sh <user> <alternate email account>"
 echo "Example: mailer.sh user_account alternate@mail.com"
 exit 0
fi

### Se valida el segundo parametro, se verifica que no sea nulo y se explica el uso correcto del script
if test -z $a_acc
then
 echo "Usage: mailer.sh <user> <alternate email account>"
 echo "Example: mailer.sh $u_acc alternate@mail.com"
 exit 0
fi

### Se verifica que la cuenta no exista, en caso de existir la cuenta se indica su existencia y termina el script
### En caso de no existir, se pregunta si se desea crear la cuenta. En caso afirmativo se crea la cuenta, de lo contrario termina el script

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
  ### se valida la que la respuesta no sea nula
  if test -z $ans
   then
    echo "Wrong answer!"
    echo "Ciao!"
    exit 0
  fi
  if [ $ans = "s" ] 
   then
    ### se genera el password del usuario de manera automatica y se asigna a la variable pasw mediante el uso de apg
    ### apg -n 1 -x 8 generara un nuevo password (-n 1) de ocho caracteres (-x 8)
    pasw=$(apg -n 1 -x 8)
    ### se crea la cuenta del usuario sin bash
    sudo useradd -m -s /bin/false -d /home/$u_acc $u_acc
    ### se le asigna el password generado automaticamente a ese usuario por medio del comando chpasswd
    echo $u_acc:$pasw > pass_tmp
    sudo chpasswd < pass_tmp
    ### se notifica en pantalla la cuenta del usuario y su password
    echo "User account: $u_acc"
    echo "Password: $pasw"
    echo " "
    echo " "
    ### se crea el entorno para la cuenta del usuario y se notifica en pantalla
    sudo mkdir /home/$u_acc/Maildir
    echo "/home/$u_acc/Maildir has been created..."
    sudo chown -R $u_acc:$u_acc /home/$u_acc/Maildir
    sudo chmod -R 700 /home/$u_acc/Maildir
    echo "Permissions assigned to the account: $u_acc"
    echo " "
    echo " "
    echo "$u_acc@mail.server.com mail account has been created..."
    ### se guarda en la variable TXT el texto que sera insertado en el archivo notificacion.txt en la linea 5 
    TXT="Usuario: $u_acc | Password: $pasw | Cuenta de correo: $u_acc@mail.server.com" 
    ### se guarda en la variable TXT1 el texto que sera insertado en el archivo notificacion.txt en la linea 17 y sera usado para enviar el correo de notificacion al usuario
    TXT1="$u_acc@mail.server.com" 
    ### se genera el archivo de notificacion personalizado para el usuario
    sed -e '5,5s/^/'"$TXT"'/' -e '17,17s/^/'"$TXT1"'/' -e '18,18s/^/'"$a_acc"'/' notificacion.txt > $u_acc'_not' 
    ### se envia el archivo de notificacion de la cuenta al usuario y a los administradores de correo, asi como el manual PDF con instrucciones de uso y configuracion
    (cat $u_acc'_not'; uuencode manual.pdf manual.pdf) | mail -s "nueva cuenta de correo Empresa" $TXT1 sysadmin@mail.server.com $a_acc 
    ### se generan los logs de actividades del script en dos archivos: mailer.log de caracter general (historico) y mail.log tiene informacion de la ultima cuenta creada
    LOG="Usuario: $u_acc | Password: $pasw | Fecha: `date` | Creada por: $USER"
    echo $LOG >> mailer.log && echo $LOG > newmail.log
    ### se envian por correo los logs de actividades del script a los administradores de correo
    (echo "Se envian logs de creacion de cuentas de correo..."; uuencode mailer.log mailer.log; uuencode newmail.log newmail.log) | mail -s "logs cuentas de correo" sysadmin@mail.server.com
    
    else
     echo "Ciao!."
     exit 0
  fi
fi
exit 0
### Aqui termina el script

### Por ultimo seria recomendable crear un enlace simbolico del script en /usr/bin/ :
### ln -s /ruta/del/script nombre_del_script.sh