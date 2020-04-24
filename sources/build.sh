#!/bin/sh
set -e

# Go the sources directory to run commands
SOURCE="${BASH_SOURCE[0]}"
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
cd $DIR
echo $(pwd)

echo "Generating Static fonts"
mkdir -p ../fonts
fontmake -m Heebo.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake -m Heebo.designspace -i -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
mkdir -p ../fonts/vf
fontmake -m Heebo.designspace -o variable --output-path ../fonts/variable/Heebo[wght].ttf


rm -rf master_ufo/ instance_ufo/ instance_ufos/


echo "Post processing"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	# python3 -m ttfautohint -l 8 -r 50 -G 200 -x 14 -D hebr -f latn -W -c $ttf "$ttf.fix";
	# mv "$ttf.fix" $ttf;
done

vfs=$(ls ../fonts/variable/*\[wght\].ttf)

echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	# ./ttfautohint-vf -l 8 -r 50 -G 200 -x 14 -D hebr -f latn -W -c --stem-width-mode nnn $vf "$vf.fix";
	# mv "$vf.fix" $vf;
done



echo "Fixing VF Meta"
gftools fix-vf-meta $vfs;

echo "Dropping MVAR"
for vf in $vfs
do
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/variable/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fixing Hinting"
for vf in $vfs
do
	gftools fix-nonhinting $vf $vf;
	# mv "$vf.fix" $vf;
done
for ttf in $ttfs
do
	gftools fix-nonhinting $ttf $ttf;
	# mv "$ttf.fix" $ttf;
done
