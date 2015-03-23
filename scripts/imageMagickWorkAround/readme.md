
# Imagemagick cannot find the default (Arial) font

`convert  label:abcdef defaultLabel.gif` fails with
`convert: unable to read font /usr/share/fonts/default/TrueType/arial.ttf`
but `convert  -font Times-Bold label:abcdef timesLabel.gif` works fine. See `testIM.bash`

## Version
```bash
convert --version
# Version: ImageMagick 6.2.8 05/07/12 Q16 file:/usr/share/ImageMagick-6.2.8/doc/index.html
# Copyright: Copyright (C) 1999-2006 ImageMagick Studio LLC
rpm -q ImageMagick
#ImageMagick-6.2.8.0-15.el5_8
cat /etc/redhat-release
# CentOS release 5.11 (Final)
```

# Work Around
create `type.xml` in IM config dir (`~/.magick`) that renames Arial as a font that does exist. See `renameArialType.xml` and `fix.bash`
