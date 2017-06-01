#!/bin/bash


IFS=$'\n'

declare -a arrPre=()
declare -a arrNow=()

sortArr()
{
  case "$1" in 
	pre) 
	 RTB=`pwd`	
	 cd ../;;
	now) 
	 cd ./;;
  esac

	declare -a arr=(`ls`)

	temp=""

	for((j = 0; j < ${#arr[@]}; j++))
	do
		if [ "`stat -c %F ${arr[$j]}`" != "디렉토리" ]
		then
			for((k = `expr $j + 1`; k < ${#arr[@]}; k++))
				do
			 		if [ "`stat -c %F ${arr[$k]}`" = "디렉토리" ]
					then
						temp=${arr[$j]}
						arr[$j]=${arr[$k]}
						arr[$k]=$temp
					fi
					
				done
		fi
	done

	lastdir=0

	for((index__lastdir = 0; index__lastdir < ${#arr[@]}; index__lastdir++))
	do
		if [ "`stat -c %F ${arr[$index__lastdir]}`" = "디렉토리" ]
		then
			lastdir=`expr $lastdir + 1`
		fi
	done

	for((m=lastdir; m < ${#arr[@]}; m++))
	do
		if [ "`stat -c %F ${arr[$m]}`" != "디렉토리" ] && [ "`stat -c %F ${arr[$m]}`" != "일반 파일" ] && [ "`stat -c %F ${arr[$m]}`" != "일반 빈 파일" ]
		then
			for((n = `expr $m + 1`; n < ${#arr[@]}; n++))
			do
				if [ "`stat -c %F ${arr[$n]}`" = "일반 파일" ] || [ "`stat -c %F ${arr[$n]}`" = "일반 빈 파일" ]
				then
					temp=${arr[$m]}
					arr[$m]=${arr[$n]}
					arr[$n]=$temp
				fi
			done
		fi
	done


	lastnorfile=0

	for((index=lastdir; index < ${#arr[@]}; index++))
	do
		if [ "`stat -c %F ${arr[$index]}`" = "일반 파일" ] || [ "`stat -c %F ${arr[$index]}`" = "일반 빈 파일" ]
		then
			lastnorfile=`expr $lastnorfile + 1`
		fi	
	done

	lastnorfile=`expr $lastnorfile + $lastdir`

	#각각 정렬
	declare -a b=()

	for((index_b = 0; index_b < lastdir; index_b++))
	do
		b[$index_b]=${arr[$index_b]}
	done

	b=( $(for el_b in "${b[@]}"
		do
			echo $el_b
		done | sort
	))

	declare -a c=()
	index_cc=0

	for((index_c = lastdir; index_c < lastnorfile; index_c++))
	do
		c[$index_cc]=${arr[$index_c]}
		index_cc=`expr $index_cc + 1`
	done

	c=( $(for el_c in "${c[@]}"
		do
			echo $el_c
		done | sort
	))

	declare -a d=()
	index_dd=0

	for((index_d = lastnorfile; index_d < ${#arr[@]}; index_d++))
	do
		d[$index_dd]=${arr[$index_d]}
		index_dd=`expr $index_dd + 1`
	done

	d=( $(for el_d in "${d[@]}"
		do
			echo $el_d
		done | sort
	))

	#결합하는 부분

	index_a=0

	for((index_BtoA = 0; index_BtoA < index_b; index_BtoA++))
	do
		arr[$index_a]=${b[$index_BtoA]}
		index_a=`expr $index_a + 1`
	done

	for((index_CtoA = 0; index_CtoA < index_cc; index_CtoA++))
	do
		arr[$index_a]=${c[$index_CtoA]}
		index_a=`expr $index_a + 1`
	done

	for((index_DtoA = 0; index_DtoA < index_dd; index_DtoA++))
	do
		arr[$index_a]=${d[$index_DtoA]}
		index_a=`expr $index_a + 1`
	done

	#..추가하기
	declare -a arr_push=()

	for((push = 0; push < ${#arr[@]}; push++))
	do
		arr_push[$push]=${arr[$push]}
	done
	
	arr[0]=".."
	push__=1	

	for((push_=0; push_ < ${#arr_push[@]}; push_++))
	do
		arr[$push__]=${arr_push[$push_]}
		push__=`expr $push__ + 1`
	done
		
	lastdir=`expr $lastdir + 1`
	lastnorfile=`expr $lastnorfile + 1`

	#조건에 따라 분기 
	case "$1" in
		pre) for((index_pre = 0; index_pre < ${#arr[@]}; index_pre++))
			do
				arrPre[$index_pre]=${arr[$index_pre]}
			done;;
		now) for((index_now = 0; index_now < ${#arr[@]}; index_now++))
			do
				arrNow[$index_now]=${arr[$index_now]}
			done;;
	esac

	if [ "$1" = "pre" ]
	then
		cd $RTB
	elif [ "$1" = "now" ]
	then 
		cd ./
	fi
}

PrintSide()
{
  sortArr "pre"
 
  RTB=`pwd`
  cd ../
 
  if [ ${#arrPre[@]} -gt 20 ]
  then
	indx__pre=20
  else
	indx__pre=${#arrPre[@]}
  fi

  for((indx_pre = 0; indx_pre < indx__pre; indx_pre++))
  do
	if [ "`stat -c %F ${arrPre[$indx_pre]}`" = "디렉토리" ]
	then
		if [ ${#arrPre[$indx_pre]} -gt 10 ]
		then
			tput cup `expr $indx_pre + 2` 1
			declare -a SName=(`sed 's/./&\n/g' <<< ${arrPre[$indx_pre]}`)

                        SNAME=$(for((sname = 0; sname < 10; sname++))
                               do
                                  printf "${SName[$sname]}"  
                               done
                                )
                                echo [34m"$SNAME"
		else
			if [ ${arrPre[$indx_pre]} = ".." ]
			then
				tput cup `expr $indx_pre + 2` 1
				echo [31m"${arrPre[$indx_pre]}"
			else
				tput cup `expr $indx_pre + 2` 1
				echo [34m"${arrPre[$indx_pre]}"
			fi
		fi
	
	elif [ "`stat -c %F ${arrPre[$indx_pre]}`" = "일반 파일" ] || [ "`stat -c %F ${arrPre[$indx_pre]}`" = "일반 빈 파일" ]
	then
		if [ ${#arrPre[$indx_pre]} -gt 10 ]
		then
			tput cup `expr $indx_pre + 2` 1
			declare -a SName=(`sed 's/./&\n/g' <<< ${arrPre[$indx_pre]}`)
                        SNAME=$(for((sname = 0; sname < 10; sname++))
                               do
                                  printf "${SName[$sname]}"  
                               done
                                )
                                echo [34m"$SNAME"
		else
			tput cup `expr $indx_pre + 2` 1
			echo [0m"${arrPre[$indx_pre]}"
		fi
	else
		if [ ${#arrPre[$indx_pre]} -gt 10 ]
		then
			tput cup `expr $indx_pre + 2` 1
			declare -a SName=(`sed 's/./&\n/g' <<< ${arrPre[$indx_pre]}`)
                        SNAME=$(for((sname = 0; sname < 10; sname++))
                               do
                                  printf "${SName[$sname]}"  
                               done
                                )
                                echo [34m"$SNAME"

		else
			tput cup `expr $indx_pre + 2` 1
			echo [32m"${arrPre[$indx_pre]}"
		fi
	fi
  done
  
  cd $RTB
}

PrintCenter()
{
  sortArr "now"

  row=2
  col=21
  count=0

  for((center = $1; center < $2; center++))
  do
	if [ "`stat -c %F ${arrNow[$center]}`" = "디렉토리" ]
	then
		if [ ${arrNow[$center]} = ".." ]
		then
			tput cup $row $col
                        echo [31m"     __"
                        tput cup `expr $row + 1` $col
                        echo [31m"/---/ |"
                        tput cup `expr $row + 2` $col
                        echo [31m"|  d  |"
                        tput cup `expr $row + 3` $col
                        echo [31m"-------"
                        tput cup `expr $row + 4` $col
			
			if [ ${#arrNow[$center]} -gt 10 ]
			then
				declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$center]}`)
				
				NAME=$(for((name = 0; name < 10; name++))
				do
					printf "${Name[$name]}"	
				done
				)
				echo [31m"$NAME"
			else
                        	echo [31m"${arrNow[$center]}"
			fi

		else
			tput cup $row $col
			echo [34m"     __"
			tput cup `expr $row + 1` $col
			echo [34m"/---/ |"
			tput cup `expr $row + 2` $col
			echo [34m"|  d  |"
			tput cup `expr $row + 3` $col
			echo [34m"-------"
			tput cup `expr $row + 4` $col
			
			if [ ${#arrNow[$center]} -gt 10 ]
                        then
                        	declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$center]}`)

                                NAME=$(for((name = 0; name < 10; name++))
                                do
                                        printf "${Name[$name]}"  
                                done
                                )
                                echo [34m"$NAME"
                        else
                                echo [34m"${arrNow[$center]}"
                        fi

		fi
	elif [ "`stat -c %F ${arrNow[$center]}`" = "일반 파일" ] || [ "`stat -c %F ${arrNow[$center]}`" = "일반 빈 파일" ]
	then
		CANIEXE=(`find ${arrNow[$center]} -perm -100`)
		if [ ${CANIEXE[0]} ]
		then
			tput cup $row $col
                        echo [31m"_______"
                        tput cup `expr $row + 1` $col
                        echo [31m"|     |"
                        tput cup `expr $row + 2` $col
                        echo [31m"|  x  |"
                        tput cup `expr $row + 3` $col
                        echo [31m"-------"
                        tput cup `expr $row + 4` $col
                        
			if [ ${#arrNow[$center]} -gt 10 ]
                        then
                       		 declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$center]}`)

                                 NAME=$(for((name = 0; name < 10; name++))
                                 do
                                        printf "${Name[$name]}"  
                                 done
                                 )
                                 echo [31m"$NAME"

                        else
                                echo [31m"${arrNow[$center]}"
                        fi

		else
			tput cup $row $col
			echo [0m"_______"
			tput cup `expr $row + 1` $col
			echo [0m"|     |"
			tput cup `expr $row + 2` $col
			echo [0m"|  o  |"
			tput cup `expr $row + 3` $col
			echo [0m"-------"
			tput cup `expr $row + 4` $col
			
			if [ ${#arrNow[$center]} -gt 10 ]
                        then
                                declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$center]}`)

                                NAME=$(for((name = 0; name < 10; name++))
                                do
                                        printf "${Name[$name]}"  
                                done
                                )
                                echo [0m"$NAME"

                        else
                                echo [0m"${arrNow[$center]}"
                        fi

		fi
	else
		tput cup $row $col
		echo [32m"_______"
		tput cup `expr $row + 1` $col
		echo [32m"|     |"
		tput cup `expr $row + 2` $col
		echo [32m"|  s  |"
		tput cup `expr $row + 3` $col
		echo [32m"-------"
		tput cup `expr $row + 4` $col
		
		if [ ${#arrNow[$center]} -gt 10 ]
                then
                     declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$center]}`)

                      NAME=$(for((name = 0; name < 10; name++))
                      	     do
                                printf "${Name[$name]}"  
                             done
                            )
                     echo [32m"$NAME"

                else
               	     echo [32m"${arrNow[$center]}"
                fi

	fi


	count=`expr $count + 1`
	if [ $count -ge 5 ]
	then
		count=0
		row=`expr $row + 5`
		col=21
	else
		col=`expr $col + 15`
	fi
  done

	#rev
  	tput rev

        if [ "`stat -c %F ${arrNow[$5]}`" = "디렉토리" ]
        then
                if [ ${arrNow[$5]} = ".." ]
                then
                        tput cup $3 $4
                        echo [31m"     __"
                        tput cup `expr $3 + 1` $4
                        echo [31m"/---/ |"
                        tput cup `expr $3 + 2` $4
                        echo [31m"|  d  |"
                        tput cup `expr $3 + 3` $4
                        echo [31m"-------"
                        tput cup `expr $3 + 4` $4

                        if [ ${#arrNow[$5]} -gt 10 ]
                        then
                                declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$5]}`)

                                NAME=$(for((name = 0; name < 10; name++))
                                do
                                        printf "${Name[$name]}" 
                                done
                                )
                                echo [31m"$NAME"
                        else
                                echo [31m"${arrNow[$5]}"
                        fi
                 else
                        tput cup $3 $4
                        echo [34m"     __"
                        tput cup `expr $3 + 1` $4
                        echo [34m"/---/ |"
                        tput cup `expr $3 + 2` $4
                        echo [34m"|  d  |"
                        tput cup `expr $3 + 3` $4
                        echo [34m"-------"
                        tput cup `expr $3 + 4` $4

                        if [ ${#arrNow[$5]} -gt 10 ]
                        then
                                declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$5]}`)

                                NAME=$(for((name = 0; name < 10; name++))
                                do
                                        printf "${Name[$name]}"  
                                done
                                )
                                echo [34m"$NAME"
                        else
                                echo [34m"${arrNow[$5]}"
                        fi

                fi
        elif [ "`stat -c %F ${arrNow[$5]}`" = "일반 파일" ] || [ "`stat -c %F ${arrNow[$5]}`" = "일반 빈 파일" ]
                then
                        CANIEXE=(`find ${arrNow[$5]} -perm -100`)
			if [ ${CANIEXE[0]} ]
                        then
                                tput cup $3 $4
                                echo [31m"_______"
                                tput cup `expr $3 + 1` $4
                                echo [31m"|     |"
                                tput cup `expr $3 + 2` $4
                                echo [31m"|  x  |"
                                tput cup `expr $3 + 3` $4
                                echo [31m"-------"
                                tput cup `expr $3 + 4` $4

                                if [ ${#arrNow[$5]} -gt 10 ]
                                then
                                         declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$5]}`)

                                        NAME=$(for((name = 0; name < 10; name++))
                                        do
                                                printf "${Name[$name]}"  
                                        done
                                         )
                                        echo [31m"$NAME"

                                else
                                        echo [31m"${arrNow[$5]}"
                                fi
                        else
                                tput cup $3 $4
                                echo [37m"_______"
                                tput cup `expr $3 + 1` $4
                                echo [37m"|     |"
                                tput cup `expr $3 + 2` $4
                                echo [37m"|  o  |"
                                tput cup `expr $3 + 3` $4
                                echo [37m"-------"
                                tput cup `expr $3 + 4` $4

                                if [ ${#arrNow[$5]} -gt 10 ]
                                then
                                        declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$5]}`)

                                        NAME=$(for((name = 0; name < 10; name++))
                                        do
                                                printf "${Name[$name]}"  
                                        done
                                         )
                                        echo [37m"$NAME"

                                else
                                        echo [37m"${arrNow[$5]}"
                                fi

                fi
        else
                tput cup $3 $4
                echo [32m"_______"
                tput cup `expr $3 + 1` $4
                echo [32m"|     |"
                tput cup `expr $3 + 2` $4
                echo [32m"|  s  |"
                tput cup `expr $3 + 3` $4
                echo [32m"-------"
                tput cup `expr $3 + 4` $4

                if [ ${#arrNow[$5]} -gt 10 ]
                then
                     declare -a Name=(`sed 's/./&\n/g' <<< ${arrNow[$5]}`)

                      NAME=$(for((name = 0; name < 10; name++))
                             do
                                printf "${Name[$name]}"  
                             done
                            )
                     echo [32m"$NAME"

                else
                     echo [32m"${arrNow[$5]}"
                fi

        fi
	tput sgr0

	tput cup 39 0
	echo "FirstIndx : $1 Lastindx in Printcenter : $2"
}

PrintInfo()
{
	tput cup 28 1
	tput el
	tput cup 28 95
	echo [0m"|"
	for((el_ = 29; el_ < 35; el_++))
	do
		tput cup $el_ 20
		tput el
		tput cup $el_ 95
		echo [0m"|"
	done

	tput cup 28 1
	echo [0m"*****************************************Information******************************************"

	#파일 이름
	tput cup 29 20
	echo [0m"file name : $1"
	
	#파일 종류
	tput cup 30 20
	if [ "`stat -c %F $1`" = "디렉토리" ]
	then
		echo [34m"file type : `stat -c %F $1`"
	elif [ "`stat -c %F $1`" = "일반 파일" ] || [ "`stat -c %F $1`" = "일반 빈 파일" ]
	then
		echo [0m"file type : `stat -c %F $1`"
	else
		echo [32m"file type : `stat -c %F $1`"
	fi
	
	#파일 사이즈
	tput cup 31 20
	echo [0m"file size : `stat -c %s $1`"
	
	#파일 생성 시간
	tput cup 32 20
	echo [0m"creation time : `stat -c %y $1`"

	#파일 권한
	tput cup 33 20
	echo [0m"permission : `stat -c %a $1`"

	#절대 경로
	tput cup 34 20
	echo [0m"absolute path : `pwd`"
	
	

}

PrintInfo_()
{
	tput cup 35 1
	echo [0m"*****************************************Information******************************************"
	
	total=0
	dir=0
	file=0
	Sfile=0
	sum=0
	
	for((sfile = 0; sfile < ${#arrNow[@]}; sfile++))
	do
		Fsize=`stat -c %s ${arrNow[$sfile]}`
		sum=`expr $sum + $Fsize`
	done

	tput cup 36 20 
	echo [0m"${#arrNow[@]} total  $lastdir dir  `expr $lastnorfile - $lastdir` file  `expr ${#arrNow[@]} - $lastnorfile` Sfile  $sum sum"
}

Update()
{

	I=0
	J=0	
	FirstIndx=0
	LastIndx=25
	Urow=2
	Ucol=21
  
  sortArr "now"

  if [ $LastIndx -ge ${#arrNow[@]} ]
  then
	LastIndx=${#arrNow[@]}
  fi  
 		tput cup 38 0
		echo "arrNow number is : ${#arrNow[@]} , LastIndx : $LastIndx" 
  tput clear
  SetFrame
  PrintSide
  PrintCenter $FirstIndx $LastIndx $Urow $Ucol `expr $J \* 5 + $I`
  PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
  PrintInfo_
	
  while true
  do		
	read -r -sn1 t
	case $t in
		A)#up
		  if [ `expr $J \* 5 + $I` -ge 0 ] && [ `expr $J \* 5 + $I` -lt 5 ]
		  then
			continue
		  else
			J=`expr $J - 1`
			if [ `expr $J \* 5 + $I` -lt $FirstIndx ] && [ `expr $J \* 5 + $I` -ge 0 ]
			then

				FirstIndx=`expr $FirstIndx - 5`
				LastIndx=`expr $LastIndx - 5`
			
				if [ $FirstIndx -lt 0 ]
				then
					FirstIndx=0
				fi

                                if [ `expr $LastIndx % 5` -ne 0 ]
                                then
                                        FillUp=`expr 5 - $LastIndx % 5`
                                        LastIndx=`expr $LastIndx + $FillUp`
                                        
                                fi
				
				tput clear
				SetFrame
				PrintSide                                
                                PrintCenter $FirstIndx $LastIndx $Urow $Ucol `expr $J \* 5 + $I`
				PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
				PrintInfo_
			else
				if [ $Urow -gt 1 ] && [ $Urow -le 22 ]
				then
					Urow=`expr $Urow - 5`
					PrintCenter $FirstIndx $LastIndx $Urow $Ucol `expr $J \* 5 + $I`
					PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
				else
					continue
				fi
			fi
		  fi ;;
		B)#down
                  if [ `expr $J \* 5 + $I` -ge `expr ${#arrNow[@]} - 5` ] && [ `expr $J \* 5 + $I` -le `expr ${#arrNow[@]} - 1` ]
                  then
                        continue
                  else
			J=`expr $J + 1`
			if [ `expr $J \* 5 + $I` -ge $LastIndx ] && [ `expr $J \* 5 + $I` -lt ${#arrNow[@]} ]
			then
				FirstIndx=`expr $FirstIndx + 5`
				LastIndx=`expr $LastIndx + 5`

				if [ $LastIndx -gt ${#arrNow[@]} ]
				then
					LastIndx=${#arrNow[@]}
				fi

				tput clear
				SetFrame
				PrintSide
				PrintCenter $FirstIndx $LastIndx  $Urow $Ucol `expr $J \* 5 + $I`
				PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
				PrintInfo_
			else
				if [ `expr $J \* 5 + $I` -lt ${#arrNow[@]} ]
				then
                               	 	if [ $Urow -ge 2 ] && [ $Urow -lt 22 ]
                               	 	then
                                        	Urow=`expr $Urow + 5`
                                        	PrintCenter $FirstIndx $LastIndx  $Urow $Ucol `expr $J \* 5 + $I`
                                        	PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
                                	fi
				else
					J=`expr $J - 1`
					continue
				fi
			fi
                  fi ;;
		C)#right
		  I=`expr $I + 1`
		  Ucol=`expr $Ucol + 15
`
		 #element not in arrNow
		  if [ `expr $J \* 5 + $I` -ge ${#arrNow[@]} ]
		  then 
			#return original status
                        I=`expr $I - 1`
                        Ucol=`expr $Ucol - 15`
                        continue		
		 #in arrNow	  	
		  else
			#is element out of 5x5 size arr?
                        if [ $I -ge 0 ] && [ $I -le 4 ]
                        then
				#in the arr
                                PrintCenter $FirstIndx $LastIndx $Urow $Ucol `expr $J \* 5 + $I`
                                PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
                        else
				#not in the arr but in arrNow size
				Temp=`expr $I - 1`
				if [ ${arrNow[`expr $J \* 5 + $Temp`]} = ${arrNow[`expr $LastIndx - 1`]} ]
				then
                               	 	I=0
					J=`expr $J + 1`
                                	Ucol=21

					FirstIndx=`expr $FirstIndx + 5`
					LastIndx=`expr $LastIndx + 5`

					if [ $LastIndx -gt ${#arrNow[@]} ]
                                	then
                                        	LastIndx=${#arrNow[@]}
                                	fi

                                	tput clear
                                	SetFrame
                                	PrintSide
                                	PrintCenter $FirstIndx $LastIndx $Urow $Ucol `expr $J \* 5 + $I`
                                	PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
                                	PrintInfo_
				else
					I=0
					J=`expr $J + 1`
					Ucol=21
					Urow=`expr $Urow + 5`

                                        PrintCenter $FirstIndx $LastIndx $Urow $Ucol `expr $J \* 5 + $I`
                                        PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
					
				fi
                        fi

		  fi;;
				
			
		D)#left
		  I=`expr $I - 1`
		  Ucol=`expr $Ucol - 15`
		  
		  #is element in arrNow?
		  if [ `expr $J \* 5 + $I` -lt 0 ]
		  then
			#no
                        I=`expr $I + 1`
                        Ucol=`expr $Ucol + 15`
                        continue		
		  else
			#yes
                        if [ $I -ge 0 ] && [ $I -le 4 ]
                        then
				#normal case
                                PrintCenter $FirstIndx $LastIndx $Urow $Ucol `expr $J \* 5 + $I`
                                PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
                        else
				#well, but, It still is in arrNow index...so, we can move to previous element
				Temp=`expr $I + 1`
				if [ $FirstIndx -ge 5 ] && [ ${arrNow[`expr $J \* 5 + $Temp`]} = ${arrNow[$FirstIndx]} ]
				then
					#scroll
					FirstIndx=`expr $FirstIndx - 5`
					LastIndx=`expr $LastIndx - 5`
					
					if [ `expr $LastIndx % 5` -ne 0 ]
					then
                                       		FillUp=`expr 5 - $LastIndx % 5`
                                        	LastIndx=`expr $LastIndx + $FillUp`
					fi
					
					I=4
					J=`expr $J - 1`
					Ucol=81

                                        tput clear
                                        SetFrame
                                        PrintSide
                                        PrintCenter $FirstIndx $LastIndx $Urow $Ucol `expr $J \* 5 + $I`
                                        PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
                                        PrintInfo_
				else
                                        I=4
                                        J=`expr $J - 1`
                                        Ucol=81
					Urow=`expr $Urow - 5`

                                        PrintCenter $FirstIndx $LastIndx $Urow $Ucol `expr $J \* 5 + $I`
                                        PrintInfo ${arrNow[`expr $J \* 5 + $I`]}
				fi
                        fi

		  fi;;
		' ')#space
		    CalcIndx=`expr $J \* 5 + $I`
		    if [ "`stat -c %F ${arrNow[$CalcIndx]}`" = "디렉토리" ]
		    then
	            	if [ ${arrNow[$CalcIndx]} = ".." ]
			then
				cd ../
				arrNow=()
				arrPre=()
				tput clear
				Update
			else
				cd ./${arrNow[$CalcIndx]}
				arrNow=()
				arrPre=()
                                tput clear
                                Update
			fi
		    else
			  declare -a CanIUse=(`find ${arrNow[$CalcIndx]} -perm -100`)
			  if [ ${CanIUse[0]} ]
			  then
                                tput cup 38 0
				tput el
				./${arrNow[$CalcIndx]}
			  else
				tput cup 38 0
				tput el
				echo [32m"Sorry you can't excute the file"
			  fi
		    fi;;
	esac
  done
}
SetFrame()
{
#바깥쪽 프레임
 tput cup 1 0
echo [0m"================================================================================================"


for((side = 2; side < 37; side++))
do
        tput cup $side 0
        echo [0m"|"

        if [ $side -lt 28 ]
        then
                tput cup $side 20
                echo [0m"|"
        fi

        tput cup $side 95
        echo [0m"|"
done

tput cup 37 0
echo [0m"================================================================================================"
}
Update

tput cup 38 0



