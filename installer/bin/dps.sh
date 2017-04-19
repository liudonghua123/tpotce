#/bin/bash

# Let's ensure normal operation on exit or if interrupted ...
function fuCLEANUP {
  stty sane
}
trap fuCLEANUP EXIT

stty -echo -icanon time 0 min 0
myIMAGES=$(cat /etc/tpot/images.conf)
while true
  do
    clear
    echo "======| System |======"
    echo Date:"     "$(date)
    echo Uptime:"  "$(uptime)
    echo CPU temp: $(sensors | grep "Physical" | awk '{ print $4 }')
    echo
    echo "NAME                CREATED		PORTS"
    for i in $myIMAGES; do
      mySTATUS=$(/usr/bin/docker ps -f name=$i --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" -f status=running -f status=exited | GREP_COLORS='mt=01;35' /bin/egrep --color=always "(^[_a-z-]+ |$)|$" | GREP_COLORS='mt=01;32' /bin/egrep --color=always "(Up[ 0-9a-Z ]+ |$)|$" | GREP_COLORS='mt=01;31' /bin/egrep --color=always "(Exited[ \(0-9\) ]+ [0-9a-Z ]+ ago|$)|$" | tail -n 1)
      myDOWN=$(echo "$mySTATUS" | grep -c "NAMES")
      if [ "$myDOWN" = "1" ];
        then
          printf "[1;35m%-19s [1;31mDown\n" $i
        else
          printf "$mySTATUS\n"
      fi
      if [ "$1" = "vv" ]; 
        then
          /usr/bin/docker exec -t $i /bin/ps -awfuwfxwf | egrep -v -E "awfuwfxwf|/bin/ps" 
      fi      
    done
    if [[ $1 =~ ^([1-9]|[1-9][0-9]|[1-9][0-9][0-9])$ ]];
      then 
        sleep $1
      else 
        break
    fi
done