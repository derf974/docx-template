#!/bin/bash

################################################################################
#
#	Cretion de template docx
#
#	Copyright (C) 2015 DerF-ITnux
#	
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#	
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#	
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

F_SED=$(mktemp)
TMP_DIR=$(mktemp -d )


usage()
{
	echo "Syntax : $0 [-d ] [-v \"VARIABLE=VALUE\" ] -i input_file -o output_file"
	exit 1
}


parse_variable()
{
	echo "${lst_var[@]}"
	for var in "${lst_var[@]}"; do
		echo "s#{{${var%%=*}}}#${var#*=}#g" >> "${F_SED}"
	done
}

del_tmp()
{
	( rm -r "${TMP_DIR}" ; rm "${F_SED}" ) 2> /dev/null
}

change_var()
{
	local f_input="$1"
	local f_output="$2"

	unzip -d "${TMP_DIR}/docx" "${f_input}" > /dev/null
	cd "${TMP_DIR}/docx" || return 1
	find "${TMP_DIR}/docx" -iname "*.xml"  | while read -r fic; do
        sed -i '' -f "${F_SED}" "$fic"
    done 
	zip -T -r ../tmp.$$.docx ./* > /dev/null 
	cd - || return 1
	cp "${TMP_DIR}"/tmp.$$.docx "${f_output}" 
	return $?
}

unset lst_var

for args ; do
	case ${args} in
		-h)usage;;
		-d)shift;set -x ;;
		-v)shift;lst_var=( "${lst_var[@]}" "$1" );shift;;
		-i)shift;input_file=$1;shift;;
		-o)shift;output_file=$1;shift;;
	esac
done

trap del_tmp EXIT

[[ -z "${input_file}" ]] && { 
    echo "[E] : Syntax error. inputfile vide"
    usage 
}

[[ -z "${output_file}" ]] && { 
    echo "[E] : Syntax error. outputfile vide" 
    usage
}

[[ ! -f "${input_file}" ]] && { 
    echo "[E] : File not exist."
    usage
}


[[ "${input_file}" =~ \.[Dd][Oo][Cc][Xx]$ ]] || { echo "[E] : File pas au format docx" && exit 1; } 

echo "-> Parsing des variables"
parse_variable
echo "-> Change les valeurs dans le fichier"
change_var "${input_file}" "${output_file}" || { echo "[E] : Sortie en erreur" ; exit 1 ;}

echo "-> Suppression des fichiers temporaires"
del_tmp

