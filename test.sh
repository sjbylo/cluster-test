MY_ROUTE=$1
MY_WAIT=0.5 
[ "$2" ] && MY_WAIT=$2
MAX_HITS=999999999
[ "$3" ] && MAX_HITS=$3

if [ ! "$MY_ROUTE" ]
then
	echo "Usage: test.sh <url> [interval] [count]"
	echo 
	echo "url:      the endpoint to test"
	echo "interval: time between each hit in seconds (default is 0.5s)"
	echo "count:    number of hits (default is no limit)"
	
	exit 0
fi

myout() {
	T1=`echo $1 | sed "s/.*\(You have.*times\).*/\1/g"`
	T2=`echo "$1"| egrep "^[a-zA-Z0-9_-]{40}$"`
	echo "$T2 $T1"  
}

CNT=0

if [ ! -f .cookie ]
then
        # Start the session
        OUT=`curl -sc .cookie $MY_ROUTE`
        myout "$OUT"

        sleep $MY_WAIT
        let CNT=$CNT+1

fi

while [ $CNT -lt $MAX_HITS ]
do
        OUT=`curl -sb .cookie $MY_ROUTE`
        myout "$OUT"

        sleep $MY_WAIT
        let CNT=$CNT+1
done

