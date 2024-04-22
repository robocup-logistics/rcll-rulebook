#! /bin/bash
#
# barcode_generator.bash
# Copyright (C) 2022 Tarik Viehmann <viehmann@kbsg.rwth-aachen.de>

MAX_DIGITS=6
QUANTITY_DIGITS=2
COLOR_DIGITS=2
PREFIX_DIGITS=$(( $MAX_DIGITS-$QUANTITY_DIGITS-$COLOR_DIGITS ))
RANGE_START=0
RANGE_END=2
NUM_COLORS=4

# red          xx0xxx
# silver       xx1xxx
# black        xx2xxx
# transparent  xx3xxx

color () {
	if (( $1 == 0 ))
		then
	 	echo	"red"
	fi
	if (( $1 == 1 ))
		then
			echo "blk"
	fi
	if (( $1 == 2 ))
		then
			echo "slv"
	fi
	if (( $1 == 3 ))
		then
			echo "tra"
	fi
}

PRINT_HELP_AND_EXIT=0
if [[ -z "$1" || -z "$2"  || -z "$3" ]]
	then
		PRINT_HELP_AND_EXIT=1
		echo "Expected a range of barcode numbers to generate. Abort."
	else
		RANGE_START=$1
		RANGE_END=$2
	if [[ "$1" == "-h" ]]
		then
			PRINT_HELP_AND_EXIT=1
		else
			echo $1
			if (( $1 >= $((10**$QUANTITY_DIGITS))  || $1 < 0 ))
				then
					echo "Argument 1 out of range. Abort"
					PRINT_HELP_AND_EXIT=1
			fi
			if (( $2 >= $((10**$QUANTITY_DIGITS))  || $2 < 0 ))
				then
					echo "Argument 2 out of range. Abort"
					PRINT_HELP_AND_EXIT=1
			fi
			if (( $1 > $2))
				then
					echo "Argument 1 cannot be greater than argument 2. Abort"
					PRINT_HELP_AND_EXIT=1
			fi
	fi

	if [[ -z "$3" ]]
		then
			PREFIX=$(printf "%0${PREFIX_DIGITS}d" $(( $RANDOM % (10**$PREFIX_DIGITS) )))
		else
		PREFIX=$3
		if (( $3 >= $((10**$PREFIX_DIGITS)) ||  $3 < 0 ))
			then
				PRINT_HELP_AND_EXIT=1
		fi
	fi
fi
HELP="
./barcodes_generator.bash <start-number> <end-number> [<prefix>]
where: <start-number> and <end-number> range between 0 and $((10**$QUANTITY_DIGITS-1))
       <prefix> is a number between 0 and $((10**$PREFIX_DIGITS-1))
                which is used as prefix of every barcode
                leave empty to get random value

Creates a directory called <prefix> containing pdfs of the barcodes and
a tex file that can generate a convenient format for printing.
"

if [[ $PRINT_HELP_AND_EXIT == 1 ]]
then
	echo "$HELP"
	exit 1
fi

PWD=$(pwd)
mkdir -p $PREFIX
cd $PREFIX
cp ../printable_barcodes.boilerplate.tex printable_barcodes.tex
count=0
for col in $(seq 0 $(($NUM_COLORS-1)) )
do
	for i in $(seq $RANGE_START $RANGE_END)
	do
		res="$PREFIX$(printf %0${COLOR_DIGITS}d $col)$(printf %0${QUANTITY_DIGITS}d $i)"
		barcode ''-b $res -e upc-e -E -n -o $res.eps'' &>/dev/null
		epstopdf $res.eps &>/dev/null
		rm $res.eps &
		pdfcrop $res.pdf $res.pdf &>/dev/null
		count_mod=$(($count % 20))
		if (($count_mod == 0))
		then
			#cat ../printable_barcodes.tex.template >> printable_barcodes.tex
			sed -i '/@@CONTENT@@/e cat ../printable_barcodes.template.tex ' printable_barcodes.tex
		fi
		sed -i "s|@@${count_mod}@@|${res}|g" printable_barcodes.tex
		sed -i "s|@@color${count_mod}@@|$(color $col)|g" printable_barcodes.tex
		count=$(($count + 1))
	done
done
		sed -i "s|.*@@.*@@.pdf}}||g" printable_barcodes.tex
		sed -i "s|@@.*@@||g" printable_barcodes.tex

cd $PWD
