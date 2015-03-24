#!/usr/bin/env bash

#
# populates subj/luna_date
#  with mprage, bars_{1..4} full of sym linked MR*s
#  also adds `filesfrom.txt` and possibly `warnings.txt`
#

set -e 
trap '[ $? -ne 0 ] && echo -e "[$(date +%F\ %H:%M)] ERROR exiting $0"' EXIT

scriptdir=$(cd $(dirname $0);pwd);
subjroot=$(cd $scriptdir/../subj; pwd);

ntaskdcm=302
nt1dcm=176
taskspersubj=4

for s in /data/Luna1/Raw/MRCTR/*_*/; do
  ld=$(basename $s)

  [[ ! $ld =~ ^[0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$ ]] &&
    echo "$ld: bad name, skipping" && continue

  ragepattern="$s/axial_mprage_256x208*"
  # do we have mprage?
  mpragedir=$(ls -d $ragepattern 2>/dev/null|tail -n1)
  [ -z "$mpragedir" -o ! -d "$mpragedir" ] && 
     echo "SKIP: $ld, no mprage dir ($ragepattern)" && continue

  nt1MR=$(ls $mpragedir/MR* 2>/dev/null| wc -l)

  [[ "$nt1MR" -ne $nt1dcm ]] &&
    echo "$ld: mprage did not have $nt1dcm dcms ($nt1MR in $mpragedir)" &&
    continue

  # search through all the tasks
  nTasks=0
  taskdirs=()
  for d in $s/BarsRewards_AntiX4_384x384.*/; do

    # if we have no task dirs we'd get an error in ls
    [ ! -d "$d" ] && continue

    nMR=$(ls $d/MR* | wc -l)

    # b/c this returns nTask before updating, this will report falure
    # the || echo captures this falure and does nothing
    let nTasks++ || echo -n ""

    # skip if we are incomplete
    [[ "$nMR" -ne $ntaskdcm ]] && continue
    # append to array fo files otherwise
    taskdirs=(${taskdirs[@]} $d)
  done


  # warn about bad numbers
  warning=""
  [[ $nTasks -ne $taskspersubj ]] && 
    warning="WARNING: $ld: found $nTasks folders (!=$taskspersubj) -- ${#taskdirs[@]} have MR* == $ntaskdcm" 

  [ $nTasks -ne ${#taskdirs[@]} -a ${#taskdirs[@]} -ne $taskspersubj ] &&
    warning="$warning\nWARNING: $ld: found $nTasks BarsReward dirs, but only ${#taskdirs[@]} have $ntaskdcm"



  subjdir="$subjroot/$ld"
  # record warnings
  [ ! -r $subjdir ] && mkdir -p $subjdir
  [ -n "$warning" ] && echo -e "$warning" > $subjdir/warnings.txt

  
  [ ${#taskdirs[@]} -le 0 ] && continue

  ## we have an mpragedir, and probably some tasks
  #  so make some files!
  #mkdir -p ../subj/$s/{mprage,bars_{1..${#taskdirs[@}}}
  newt1dir=$subjroot/$ld/mprage
  if [ ! -d  $newt1dir ]; then
   mkdir -p $newt1dir
   ln -s $mpragedir/MR* $newt1dir/
   echo "mprage $mpragedir" > $subjdir/filesfrom.txt
  else
    echo "$ld: already have $newt1dir"
  fi

  nTask=0
  for origtask in ${taskdirs[@]}; do
   let nTask++ || echo -n ""
   taskdir=$subjroot/$ld/bars_$nTask
   [ -d $taskdir ] && echo "$ld: have $taskdir" && continue
   mkdir -p $taskdir
   ln -s $origtask/MR* $taskdir/
   echo "bars_$nTask $origtask" >> $subjdir/filesfrom.txt
  done
  
done
