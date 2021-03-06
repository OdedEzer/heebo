#!/bin/sh
set -e

# Go the sources directory to run commands
SOURCE="${BASH_SOURCE[0]}"
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
cd $DIR
echo $(pwd)

rm -rf ../fonts

echo "Generating Static fonts"
mkdir -p ../fonts
fontmake -m Heebo.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake -m Heebo.designspace -i -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
mkdir -p ../fonts/variable
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
echo $(ls ../fonts/variable)



echo "Fixing VF Meta"
gftools fix-vf-meta $vfs;
for vf in $vfs
do
	mv $vf.fix $vf;
done

echo $(ls ../fonts/variable)

echo "Dropping MVAR"
for vf in $vfs
do
	gftools fix-unwanted-tables -t MVAR $vf;
done

echo "Fixing Hinting"
for vf in $vfs
do
	gftools fix-nonhinting $vf $vf;
done
echo $(ls ../fonts/variable)
for ttf in $ttfs
do
	gftools fix-nonhinting $ttf $ttf;
	# mv "$ttf.fix" $ttf;
done

rm -f ../fonts/ttf/*gasp.ttf ../fonts/variable/*gasp.ttf
