#!/bin/bash
function isDateValid {
    DATE=$1

    if [[ $DATE =~ ^[0-9]{1,2}.[0-9a-zA-Z]{1,3}.[0-9]{4}$ ]]; then
        echo "Date $DATE is a number!"
        day=`echo $DATE | cut -d'.' -f1`
        month=`echo $DATE | cut -d'.' -f2`
        year=`echo $DATE | cut -d'.' -f3`

                if [ "$month" == "01" ] || [ "$month" == "1" ]; then
                        month="Jan"
                elif [ "$month" == "02" ] || [ "$month" == "2" ]; then
                        month="Feb"
                elif [ "$month" == "03" ] || [ "$month" == "3" ]; then
                        month="Mar"
                elif [ "$month" == "04" ] || [ "$month" == "4" ]; then
                        month="Apr"
                elif [ "$month" == "05" ] || [ "$month" == "5" ]; then
                        month="May"
                elif [ "$month" == "06" ] || [ "$month" == "6" ]; then
                        month="Jun"
                elif [ "$month" == "07" ] || [ "$month" == "7" ]; then
                        month="Jul"
                elif [ "$month" == "08" ] || [ "$month" == "8" ]; then
                        month="Aug"
                elif [ "$month" == "09" ] || [ "$month" == "9" ]; then
                        month="Sep"
                elif [ "$month" == "10" ]; then
                        month="Oct"
                elif [ "$month" == "11" ]; then
                        month="Nov"
                elif [ "$month" == "12" ]; then
                        month="Dec"
                fi

        ymd=$year"-"$month"-"$day
        echo "ymd: "$ymd
        dmy=$(echo "$ymd" | awk -F- '{ OFS=FS; print $3,$2,$1 }')
        echo "dmy: "$dmy
        if date --date "$dmy" >/dev/null 2>&1; then
                echo "OK"
            return 0
        else
                echo "NOK"
            return 1
        fi
    else
        echo "Date $DATE is not a number"
        return 1
    fi
}
function isValidateTime() {
	ret=$(echo $element | awk -F ':' '{ print ($1 <= 23 && $2 <= 59 && $3 <= 59) ? 1 : 0 }')
	if $ret = 1
	then
		return 1
	elif
		return 0
	fi
}
while IFS='' read -r line || [[ -n "$line" ]]; do
   # echo "Text read from file: $line"
	#echo $line | sed 's/ /\n/g' 
	vals=$(echo $line | tr " " "\n")
	echo "-------------------"
	var=0
	for element in $vals
	do
		#echo "$element"
		var=$((var + 1))
		if [ $var = 1 ] 
		then
			echo "$element"
			#if isDateValid $element; then
			#	echo "date is valid =)"
			#else
			#	echo "bad format date"
			#fi 
		elif [ $var = 2 ] 
		then 
			echo "$element"
			if isValidateTime $element; then
				echo "time is valid =)"
			else
				echo "bad format time"
			fi 
		fi
	done
done < "$1"

