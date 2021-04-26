#!/bin/bash --posix

bsh_name="./42sh"
bsh_pos="bash --posix"
sl=0.4


function my_echo {
	
	echo -n " [ "
	if [ "$1" = "$2" ]
	then
		echo -e "\033[32;1mSUCCESS \033[0m]"
	else
		echo -e "\033[31;1mFAULT \033[0m]"
		echo "[your \""$1"\"] [original \""$2"\"]"
	fi
	echo
}


function delay {
	
	echo -en "\033[32;1mLoading "
	for (( i=1; i <= 5; i++ ))
	do
		echo -n "#"
		sleep $sl
	done
	echo -e "\033[0m"
}


function print_name {
	echo -e "                              $1"
	sleep 1.2
}


delay

start_check(){
if [ -x $bsh_name ]
then
	echo
	print_name "\033[42;1m###START CHECKS###\033[0m\n\n"
else
    echo -e "\033[31;1mERROR: no such $bsh_name file\033[0m"
    exit
fi
sleep $sl
}


##PARSER##


check_parser(){
print_name "\033[45;1m____TEST PARSER____\033[0m\n"

echo -n "---test non existen command---"
err=$($bsh_name -c "ololo" 2>&1)
suc="e-bash: ololo: Command not found"
my_echo "$err" "$suc"
sleep $sl

echo -n "---test >---"
err=$($bsh_name -c "ls nonexisten 2>&1 | cat -e 1>&2 | cat -e" 2>&1)
suc=$($bsh_pos -c "ls nonexisten 2>&1 | cat -e 1>&2 | cat -e" 2>&1)
my_echo "$err" "$suc"
sleep $sl

echo -n "---test &&---"
err=$($bsh_name -c "ls sdfdsf && echo NO" 2>&1)
suc="ls: sdfdsf: No such file or directory"
my_echo "$err" "$suc"
sleep $sl

echo -n "---test ||---"
err=$($bsh_name -c "ls sdfsdf || echo YES | cat -e" 2>&1)
suc="ls: sdfsdf: No such file or directory
YES$"
my_echo "$err" "$suc"
sleep $sl

echo "---complex test---"
#$err=$($bsh_name -c "FOO=123; echo \${FOO} >/dev/null && echo YES ; unset FOO" 2>&1)
#$suc="YES"
#my_echo "$err" "$suc"
sleep $sl
}


##CD##


check_cd(){
print_name "\033[45;1m____TEST CD____\033[0m\n"

echo -n "---test permission---"
mkdir ~/test1
chmod 000 ~/test1
err=$($bsh_name -c "cd ~/test1" 2>&1)
cd
path=$(pwd)
cd - 1>&-
suc="e-bash: cd: $path/test1: Permission denied"
my_echo "$err" "$suc"
chmod 777 ~/test1
rm -rf ~/test1
sleep $sl

echo -n "---test 'no such file or directory'---"
err=$($bsh_name -c "cd ololo" 2>&1)
suc="e-bash: cd: ololo: No such file or directory found"
my_echo "$err" "$suc"
sleep $sl

echo -n "---test cd without arguments---"
err=$($bsh_name -c "cd; pwd" 2>&1)
suc=$($bsh_pos -c "cd; pwd" 2>&1)
my_echo "$err" "$suc"
sleep $sl

echo -n "---test unset \$HOME---"
err=$($bsh_name -c "unset HOME; cd" 2>&1)
suc="e-bash: cd: HOME not set"
my_echo "$err" "$suc"
sleep $sl

echo -n "---test absolute path---"
err=$($bsh_name -c "cd /; pwd" 2>&1)
suc=$($bsh_pos -c "cd /; pwd" 2>&1)
my_echo "$err" "$suc"
sleep $sl

echo -n "---test too many arguments---"
err=$($bsh_name -c "cd / / / /" 2>&1)
suc="e-bash: cd: Too many arguments"
my_echo "$err" "$suc"
sleep $sl

echo -n "---test CDPATH---"
mkdir ~/test_cdpath
err=$($bsh_name -c "export CDPATH=~ ; cd test_cdpath; pwd" 2>&1)
suc=$($bsh_pos -c "CDPATH=~ cd test_cdpath; pwd" 2>&1)
my_echo "$err" "$suc"
rm -rf ~/test_cdpath
sleep $sl

echo -n "---test CDPATH error---"
err=$($bsh_name -c "CDPATH=~ cd test_cdpath" 2>&1)
suc="e-bash: cd: test_cdpath: No such file or directory found"
my_echo "$err" "$suc"
sleep $sl
}


##ECHO##


check_echo(){
print_name "\033[45;1m____TEST ECHO____\033[0m\n"

echo -n "---test echo without arguments---"
err=$($bsh_name -c "echo")
suc=$($bsh_pos -c "echo")
my_echo "$err" "$suc"
sleep $sl

echo -n "---test invalid flags---"
err=$($bsh_name -c "echo -rt" 2>&1)
suc="e-bash: echo: Invalid option
echo: usage: echo [-neE] [arg ...]"
my_echo "$err" "$suc"
sleep $sl

echo -n "---test many arguments---"
err=$($bsh_name -c "echo abc def 123" 2>&1)
suc=$($bsh_pos -c "echo abc def 123" 2>&1)
my_echo "$err" "$suc"
sleep $sl

echo -n "---test signals---"
err=$($bsh_name -c "echo -en \"\\vabcd\\n\"" 2>&1) 
suc=$($bsh_pos -c "echo -en \"\\vabcd\\n\"" 2>&1)
my_echo "$err" "$suc"
sleep $sl
}


##UNSET##


check_unset(){
print_name "\033[45;1m____TEST UNSET____\033[0m\n"

echo -n "---test without arguments---"
err=$($bsh_name -c "unset" 2>&1)
suc=$($bsh_pos -c "unset" 2>&1)
my_echo "$err" "$suc"
sleep $sl

echo -n "---test readonly variable---"
err=$($bsh_name -c "unset UID=testtest" 2>&1)
suc="e-bash: unset: UID: Readonly variable"
my_echo "$err" "$suc"
sleep $sl

echo -n "---test delete several variables---"
err=$($bsh_name -c "unset HOME PWD OLDPWD; env | grep HOME; env | grep PWD" 2>&1)
suc=$($bsh_pos -c "unset HOME PWD OLDPWD; env | grep HOME; env | grep PWD" 2>&1)
my_echo "$err" "$suc"
sleep $sl

echo -n "---test create and delete variable---"
err=$($bsh_name -c "foo=bar; unset foo; env | grep foo" 2>&1)
suc=$($bsh_pos -c "foo=bar; unset foo; env | grep foo" 2>&1)
my_echo "$err" "$suc"
sleep $sl
}


##EXPORT##


check_export(){
print_name "\033[45;1m____TEST EXPORT____\033[0m\n"

echo -n "---test several arguments---"
err=$($bsh_name -c "export foo=bar faa=bur ; env | grep foo; env | grep faa" 2>&1)
suc=$($bsh_pos -c "export foo=bar faa=bur ; env | grep foo; env | grep faa" 2>&1)
my_echo "$err" "$suc"
sleep $sl

echo -n "---test readonly variable---"
err=$($bsh_name -c "export UID=dfbv" 2>&1)
suc="e-bash: export: UID: Readonly variable"
my_echo "$err" "$suc"
sleep $sl

echo -n "---test create empty variable---"
err=$($bsh_name -c "export fii lii=; env | grep fii; env | grep lii" 2>&1)
suc=$($bsh_pos -c "export fii lii=; env | grep fii; env | grep lii" 2>&1)
my_echo "$err" "$suc"
sleep $sl

echo -n "---test invalid option---"
err=$($bsh_name -c "export -djhb PATH=sjhvg" 2>&1)
suc="e-bash: export: Invalid option
export: usage: export [name[=value] ...] or export -p"
my_echo "$err" "$suc"
}


##LOGIC##


arr=("check_parser" "check_cd" "check_echo" "check_unset" "check_export" "--full")
usage="\nusage ./test.sh [options]:\n    --full             - full check\n    check_[block_name] - check needed block only
   
    usable blocks:
    parser, cd, echo, unset, export

\033[31;1mALERT!!!!
IF YOU ARE USING MACOS, USE \"BASH AUTOTEST.SH\"\033[0m"

if [ $# -gt 0 ]
then
	for cmd in $@
	do
		i=0
		for ex in ${arr[@]}
		do
			if [ "$cmd" = "$ex" ]
			then
				i=1
				break
			fi
		done
		if [ $i -eq 0 ]
		then
			echo invalid option "$cmd"
			echo -e "$usage"
			exit
		fi
	done
fi

if [ $# -eq 1 ] && [ "$1" = "--full" ]
then
	start_check
	check_parser
	check_cd
	check_echo
	check_unset
	check_export
elif [ $# -gt 0 ]
then
	start_check
	for i in $@
	do
		"$i"
	done

else
	echo -e "$usage"
fi

echo -e "\033[34;2mCreated by kfalia-f\033[m"
#print_name "\033[42;1m###END OF TESTS###\033[0m"
