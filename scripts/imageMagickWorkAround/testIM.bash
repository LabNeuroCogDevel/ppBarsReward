convert  label:abcdef defaultLabel.gif
convert  -font Times-Bold label:abcdef timesLabel.gif
# will fail on CentOS 5.11 b/c arial.ttf is not where it's expected
#  convert: unable to read font `/usr/share/fonts/default/TrueType/arial.ttf'
# `identify -list type` shows it is an aviable font
# » convert --version
# Version: ImageMagick 6.2.8 05/07/12 Q16 file:/usr/share/ImageMagick-6.2.8/doc/index.html
#  Copyright: Copyright (C) 1999-2006 ImageMagick Studio LLC



# preprocessFunctional hits bug with:
#   bettedRefBrain=$HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_brain_2mm
#   slicer "$bettedRefBrain" mprage_bet_warped -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png
#   pngappend sla.png + slb.png + slc.png + sld.png - sle.png + slf.png + slg.png + slh.png - sli.png + slj.png + slk.png + sll.png highres2standard1.png
#   montage -label "Subject brain with template outline overlaid" highres2standard1.png -pointsize 30 -geometry +0+0 highres2standard1.png 
