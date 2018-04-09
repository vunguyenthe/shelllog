#!/bin/bash
declare -r MAX_LEN_PER_LINE=128
DATE_WRONG_LINES=()
TIME_WORNG_LINES=()
META_WRONG_LINES=()
TEXT_TOO_LONG_LINES=()
function isDateValid {
    DATE=$element

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
function isTimeValid() {
	TIME=$element
	ret=$(echo $TIME | awk -F ':' '{ print ($1 <= 23 && $2 <= 59 && $3 <= 59) ? 1 : 0 }')
	if [ $ret = 1 ]; then
		echo "OK"
		return 0
    else
		echo "NOK"
		return 1
    fi
}
function isMetaInfoValid() {
	META=$line
	if [[ $META =~ "DEBUG:" || $META =~ "INFO:" || $META =~ "WARN:" || $META =~ "ERROR:" ]]; then
		echo "matched"
		return 0;
	else
		echo "didn't match"
		return 1;
	fi
}
function isTextLengthValid() {
	TEXT=$line
	iLen=${#TEXT}
	if [[ iLen < $MAX_LEN_PER_LINE ]]; then 
		return 0
	else
		return 1
	fi
}
mwIdx=0
twIdx=0
while IFS='' read -r line || [[ -n "$line" ]]; do
   # echo "Text read from file: $line"
	#echo $line | sed 's/ /\n/g' 
	vals=$(echo $line | tr " " "\n")
	#echo $line
	lineNumber=$((lineNumber + 1))
	echo "-------------------Line numner: $lineNumber"
	#valiate meta info
	if isMetaInfoValid $line; then 
		echo "meta info line number: $lineNumber is valid =)"
	else 
		echo "bad format meta info line number: $lineNumber =)"
		META_WRONG_LINES[mwIdx]=lineNumber
		mwIdx=$((mwIdx + 1))
	fi	
	#validate length of a string , for now we defined length is 128 per line 
	if isTextLengthValid $line; then 
		echo "Length is ok"
	else 
		echo "Length is too long"
		TEXT_TOO_LONG_LINES[twIdx]=lineNumber
		twIdx=$((twIdx + 1))
	fi
	#valiate date & time 
	var=0
	dwIdx=0
	twIdx=0
	for element in $vals
	do
		#echo "$element"
		var=$((var + 1))
		if [ $var = 1 ] 
		then
			#echo "$element"
			if isDateValid $element; then
				echo "date is valid =)"
			else
				echo "bad format date"
				DATE_WRONG_LINES[dwIdx]=lineNumber
				dwIdx=$((dwIdx + 1))
			fi 
		elif [ $var = 2 ] 
		then 
			#echo "$element"
			if isTimeValid $element; then
				echo "time is valid =)"
			else
				echo "bad format time"
				TIME_WORNG_LINES[twIdx]=lineNumber 
				twIdx=$((twIdx + 1))
			fi 
		fi
	done
done < "$1"

