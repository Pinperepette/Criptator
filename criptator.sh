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


########################################################################
#Maschera immissione metodo cripaggio / decriptaggio
#ottengo la variabile "metodo"
maschera_metodo(){
metodo=`zenity --list --width=250 --height=250 \
  --title="C R I P T A T O R" \
  --text="Seleziona un algoritmo" \
  --column="Algoritmi" \
  "aes256" \
  "desx" \
  "cast" \
  "rc4" \
  "des3" \
  "base64"`
}
########################################################################
#Maschera immissione azione cripta / decripta
#ottengo la variabile "azione"
maschera_cripta_decripta(){
azione=`zenity --list --width=250 --height=250 \
  --title="C R I P T A T O R" \
  --text="Cosa vuoi fare ?" \
  --column="Azioni" \
  "Cripta" \
  "Decripta"`
}
########################################################################
#Maschera seleziona file
#ottengo la variabile "file"
maschera_seleziona_file(){
file=`zenity --file-selection --title="Seleziona File"` 
}
########################################################################
#Maschera immissione password
#ottengo la variabile "password"
maschera_immissione_password(){
password=`zenity --entry --title="C R I P T A T O R" --text="Inserisci la password:" --entry-text "password" --hide-text`    
}   
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

maschera_metodo

#se il campo è vuoto esci,altrimenti continua...
	if [ -z "$metodo" ]; then
	   exit
	else  
	maschera_cripta_decripta 
	fi

#se il campo è vuoto esci,altrimenti continua...
	if [ -z "$azione" ] ; then
		 exit
	else
	maschera_seleziona_file
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
	maschera_immissione_password
	fi 

#se il campo è vuoto esci,altrimenti continua...
	if [ -z "$password" ] ; then
		 exit
	else
	esegui
	cancella
	fi 
	exit

