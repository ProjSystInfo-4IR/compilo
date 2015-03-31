# find current directory full path
CUR_DIR="`(dirname \"$0\")`"
CUR_DIR="`( cd \"$CUR_DIR\" && pwd )`"

cd $CUR_DIR/..

# find all c test files 
C_FILES="$(find $CUR_DIR/*.c)"
for FILE in `echo $C_FILES`; do
	simpleName=${FILE##*/}
	simpleNameNE=${simpleName%.c}
	echo -e "\e[39m"$simpleName":"
	# analyze each file
	./cible $FILE -o build/$simpleNameNE.asm > /dev/null
	if [ "$?" -eq 0 ] 
	then
		echo -e '\e[92mTest passed'
	else 
		# rerun if failed
		echo -e '\033[31m Test failed'
		./cible $FILE
	fi
done

echo -e "\e[39mDone."