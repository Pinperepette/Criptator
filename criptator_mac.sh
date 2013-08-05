#!/bin/bash
########################################################################
# by PINPEREPETTE (the Pirate)                                         #
########################################################################
# This program is free software; you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation; either version 2 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program; if not, write to the Free Software          #
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,           #
# MA 02110-1301, USA.                                                  #
############################# DISCALIMER ###############################
# Usage of this software for probing/attacking targets without prior   #
# mutual consent, is illegal. It's the end user's responsability to    #
# obey alla applicable local laws. Developers assume no liability and  #
# are not responible for any missue or damage caused by thi program    #
########################################################################

#Per la gui uso una sorta di framework (pashua)
#Questo mi permette di non usare X ne sdk :P
#X su mac è la merda... sdk peggio :P
gui_set() {

	pashua_configfile=`/usr/bin/mktemp /tmp/pashua_XXXXXXXXX`
	echo "$1" > $pashua_configfile
	bundlepath="Criptator.app/Pashua.app/Contents/MacOS/Pashua"
	if [ "$3" = "" ]
	then
		mypath=`dirname "$0"`
		for searchpath in "$mypath/Pashua" "$mypath/$bundlepath" "./$bundlepath" \
						  "/Applications/$bundlepath" "$HOME/Applications/$bundlepath"
		do
			if [ -f "$searchpath" -a -x "$searchpath" ]
			then
				pashuapath=$searchpath
				break
			fi
		done
	else
		pashuapath="$3/$bundlepath"
	fi

	if [ ! "$pashuapath" ]
	then
		echo "Error: Pashua could not be found"
		exit 1
	fi
	
	if [ "$2" = "" ]
	then
		encoding=""
	else
		encoding="-e $2"
	fi

	result=`"$pashuapath" $encoding $pashua_configfile | sed 's/ /;;;/g'`

	# Rimuovo i file di configurazione
	rm $pashua_configfile


	for line in $result
	do
		key=`echo $line | sed 's/^\([^=]*\)=.*$/\1/'`
		value=`echo $line | sed 's/^[^=]*=\(.*\)$/\1/' | sed 's/;;;/ /g'`		
		varname=$key
		varvalue="$value"
		eval $varname='$varvalue'
	done

} 

###############################################################################################
#Maschera immissione metodo cripaggio / decriptaggio
#ottengo la variabile "metodo"
maschera_metodo="
# Set transparency: 0 is transparent, 1 is opaque
*.transparency=0.95

# Set window title
*.title = C R I P T A T O R

metodo.type = radiobutton
metodo.label = Seleziona un algoritmo
metodo.option = aes256
metodo.option = desx
metodo.option = cast
metodo.option = rc4
metodo.option = des3
metodo.option = base64

tb.type = text
tb.default = Questa maschera ti permette di decidere come Criptare o Decriptare un file.
tb.height = 276
tb.width = 310
tb.x = 340
tb.y = 44

# Add a cancel button with default label
cb.type=cancelbutton
"

########################################################################
#Maschera immissione azione cripta / decripta
#ottengo la variabile "azione"
maschera_cripta_decripta="
# Set transparency: 0 is transparent, 1 is opaque
*.transparency=0.95

# Set window title
*.title = C R I P T A T O R

azione.type = radiobutton
azione.label = Cosa vuoi fare ?
azione.option = Cripta
azione.option = Decripta

tb.type = text
tb.default = Questa maschera ti permette di decidere se Criptare o Decriptare un file.
tb.height = 276
tb.width = 310
tb.x = 340
tb.y = 44
"
########################################################################
#Maschera seleziona file
#ottengo la variabile "file"
maschera_seleziona_file="
# Set transparency: 0 is transparent, 1 is opaque
*.transparency=0.95

# Set window title
*.title = C R I P T A T O R

file.type = openbrowser
file.label = Seleziona il file
file.width=310
file.tooltip = Blabla filesystem browser
"
########################################################################
#Maschera immissione password
#ottengo la variabile "password"
maschera_immissione_password="
# Set transparency: 0 is transparent, 1 is opaque
*.transparency=0.95

# Set window title
*.title = C R I P T A T O R

password.type = password
password.label = Inserisci la Password
password.default = Secret!
password.width = 120
"
########################################################################

#Cripta/Decripta
esegui(){
com=openssl	
met="-$metodo"
pass="-pass pass:$password"
$com $action $met -in $file -out $out $pass	
digerisci $file $out
	}
########################################################################
#Vado a cancellare il file originale
#per farlo controllo su che macchina gira
#e agisco di conseguenza :P 
cancella() {
	if [ $(uname -s) == 'Darwin' ]; then
		srm $file
	elif [ $(uname -s) == 'Linux' ]; then
		shred -u $file
	fi
}
########################################################################
digerisci() {    
	openssl dgst -md5 $1
	openssl dgst -md5 $2
}

gui_set "$maschera_metodo"

#se il campo è vuoto esci,altrimenti continua...
	if [ -z "$metodo" ]; then
	   exit
	else  
	gui_set "$maschera_cripta_decripta" 
	fi

#se il campo è vuoto esci,altrimenti continua...
	if [ -z "$azione" ] ; then
		 exit
	else
	gui_set "$maschera_seleziona_file"
	fi 

#setto la variabile action in base alla variabile azione
#e di conseguenza determino in nome del file di ouput   
	case $azione in
		Cripta) action=enc ; out="$file.$metodo" ;;
		Decripta) action="enc -d" ; out="$file.$metodo.decript" ;;
		(*) exit;;
	esac

#se il campo è vuoto esci,altrimenti continua...
	if [ -z "$file" ] ; then
		 exit
	else
	gui_set "$maschera_immissione_password"
	fi 

#se il campo è vuoto esci,altrimenti continua...
	if [ -z "$password" ] ; then
		 exit
	else
	esegui
	cancella
	fi 
	exit
