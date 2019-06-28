#!/bin/bash
acum=0
c=10

#httping https://www.google.com -c $c > temp.txt;
media=$(tail -n 1 temp.txt | awk '{print $4}' | cut -d "/" -f2)
media=${media%.*}

while read line
do
    if [[ $line == connected* ]];
    then
       data=$(echo "$line" | awk '{print $7}' | cut -d"=" -f2)
       data=${data%.*}
       temp=$(($data - $media)) #xi - media
       temp2=$(($temp*$temp)) #(xi-media)^2
       acum=$(($acum+$temp2)) #somatorio
    fi
done < "temp.txt"
n=$(($c-1))
variancia=$(($acum/$n)) #somatorio/(n-1)
echo "variancia= $variancia"
dpad=$(echo "sqrt ( $variancia )" | bc -l) ; echo $dpad
