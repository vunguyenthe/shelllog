#!/bin/bash
declare -r MAX_LEN_PER_LINE=128
function isDateValid {
    DATE=$element

    if [[ $DATE =~ ^[0-9]{1,2}.[0-9a-zA-Z]{1,3}.[0-9]{4}$ ]]; then
        #echo "Date $DATE is a number!"
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
        #echo "ymd: "$ymd
        dmy=$(echo "$ymd" | awk -F- '{ OFS=FS; print $3,$2,$1 }')
        #echo "dmy: "$dmy
        if date --date "$dmy" >/dev/null 2>&1; then
            #echo "OK"
            return 0
        else
            #echo "NOK"
            return 1
        fi
    else
        #echo "Date $DATE is not a number"
        return 1
    fi
}
function isTimeValid() {
	TIME=$element
	ret=$(echo $TIME | awk -F ':' '{ print ($1 <= 23 && $2 <= 59 && $3 <= 59) ? 1 : 0 }')
	if [ $ret = 1 ]; then
		return 0
    else
		return 1
    fi
}
function isMetaInfoValid() {
	META=$line
	if [[ $META =~ "DEBUG:" || $META =~ "INFO:" || $META =~ "WARN:" || $META =~ "ERROR:" ]]; then
		#echo "matched"
		return 0;
	else
		#echo "didn't match"
		return 1;
	fi
}
function isTextLengthValid() {
	TEXT=$line
	iLen=${#TEXT}
	if [[ iLen -lt $MAX_LEN_PER_LINE ]]; then 
		return 0
	else
		return 1
	fi
}
#---------------main function-----------
mwIdx=0
twIdx=0
DATE_WRONG_LINES=()
TIME_WORNG_LINES=()
META_WRONG_LINES=()
TEXT_TOO_LONG_LINES=()
while IFS='' read -r line || [[ -n "$line" ]]; do
	vals=$(echo $line | tr " " "\n")
	lineNumber=$((lineNumber + 1))
	if ! isMetaInfoValid $line; then  
		META_WRONG_LINES+=($lineNumber)
	fi	
	if ! isTextLengthValid $line; then 
		TEXT_TOO_LONG_LINES+=($lineNumber)
	fi
	var=0
	dwIdx=0
	twIdx=0
	for element in $vals
	do
		var=$((var + 1))
		if [ $var = 1 ] 
		then
			if  isTimeValid $element; then
				break;
			fi		
			if ! isDateValid $element; then
				DATE_WRONG_LINES+=($lineNumber)
			fi 
		elif [ $var = 2 ] 
		then 
			if ! isTimeValid $element; then
				TIME_WORNG_LINES+=($lineNumber)
			fi 
		fi
	done
done < "$1"
#---------------output result is here-----------
#date validation
iDateWrongLen=${#DATE_WRONG_LINES}
iTimeWrongLen=${#TIME_WORNG_LINES}
iMetaWrongLen=${#META_WRONG_LINES}
iTextTooLongLen=${#TEXT_TOO_LONG_LINES}

if [[ $iDateWrongLen -gt 0 || $iDateWrongLen -gt 0 ||  $iDateWrongLen -gt 0 || $iDateWrongLen -gt 0 ]]; then
	echo "--------Failed with summary----------"
	printf "Date: %s errors\n" "$iDateWrongLen"	
	printf "Time: %s errors\n" "$iTimeWrongLen"	
	printf "MetaInfo: %s errors\n" "$iMetaWrongLen"	
	printf "Text too long: %s errors\n" "$iTextTooLongLen"	

	echo "--------Failed with details---------"
	printf 'Date wrong lines: '
	printf "%s " "${DATE_WRONG_LINES[@]}"	
	printf "\n"
	#time validation
	printf 'Time wrong lines: '
	printf "%s " "${TIME_WORNG_LINES[@]}"	
	printf "\n"
	#meta validation
	printf 'Meta wrong lines: '
	printf "%s " "${META_WRONG_LINES[@]}"	
	printf "\n"
	#Text validation
	printf 'Text too long lines: '
	printf "%s " "${TEXT_TOO_LONG_LINES[@]}"	
	printf "\n"
else 
	echo "--------Success with summary----------"
	printf "Date: %s errors\n" "$iDateWrongLen"	
	printf "Time: %s errors\n" "$iTimeWrongLen"	
	printf "MetaInfo: %s errors\n" "$iMetaWrongLen"	
	printf "Text too long: %s errors\n" "$iTextTooLongLen"	
		
fi

