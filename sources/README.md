# Heebo Build Instructions

Open the Glyphs file, and go to File menu, Export. 

Export with Remove Overlap and Autohinting and not TTF, and move them into fonts/otf

Export with Remove Overlap and Not Autohinting and TTF, and move them into fonts/ttf

Autohint using ttfautohint by hand:

    for font in `ls -1 fonts/ttf/*.ttf`; do \
    ttfautohint --composites --default-script=hebr --fallback-script=latn \
    --detailed-info --windows-compatibility $font $font.ta; \
    done;
    rm fonts/ttf/*ttf;
    rename s/ttf.ta/ttf/g fonts/ttf/*ta;

Then convert the binaries to ttx in split mode:

    ttx -s fonts/*/*tf;
    rm fonts/*tf/*tf;
