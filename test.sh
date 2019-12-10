MY_ROUTE=$1
MY_WAIT=0.5 
[ "$2" ] && MY_WAIT=$2
MAX=999999999
[ "$3" ] && MAX=$3


myout() {
	T1=`echo $1 | sed "s/.*\(You have.*times\).*/\1/g"`
	T2=`echo "$1"| egrep "^[a-zA-Z0-9_-]{40}$"`
	echo "$T2 $T1"  
}

# Start the session
OUT=`curl -sc .cookie $MY_ROUTE`
myout "$OUT"

sleep $MY_WAIT

cnt=1
while [ $cnt -lt $MAX ]
do
	OUT=`curl -sb .cookie $MY_ROUTE`
	myout "$OUT"

	sleep $MY_WAIT
	let cnt=$cnt+1
done

