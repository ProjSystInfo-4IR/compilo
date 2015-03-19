# find current directory full path
CUR_DIR="`(dirname \"$0\")`"
CUR_DIR="`( cd \"$CUR_DIR\" && pwd )`"

# find all c test files 
C_FILES="$(find $CUR_DIR/*.c)"
for FILE in `echo $C_FILES`; do
	echo -e "\e[39m"$FILE":"
	# analyze each file
	cat $FILE | $CUR_DIR/../cible > /dev/null
	if [ "$?" -eq 0 ] 
	then
		echo -e '\e[92mTest passed'
	else 
		# rerun
		echo -e '\033[31m Test failed'
		cat $FILE | $CUR_DIR/../cible
	fi
done

echo -e "\e[39mDone."