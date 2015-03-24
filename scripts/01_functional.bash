#!/usr/bin/env bash

#
# find all subjects without final preprocessed functional
#  1. run mprage with ppt1_pbs.bash (if already done, will exit succesfully)
#  2. run func   with ppt2_pbs.bash, depend on mprage


## ultimately all we are doing is this for each run
#
# mid=$(qsub  ppt1_pbs.bash \
#         -v T1PATH="/raid/r5/p1/Luna/Bars/subj/10153_20111128/mprage)" 
# qsub ppt2_pbs.bash -W depend=afterok:$mid \
#         -v T2PATH="/raid/r5/p1/Luna/Bars/subj/10153_20111128/bars_1




subjroot="/raid/r5/p1/Luna/Bars/subj/"

## USAGE: getid PBS_JOBNAME
## returns id or error
# echo the id of the name in the queue if it's a string of digitis
# otherwise error out
function getid {
  name="$@"
  # return error, but dont say anything
  [ -z "$name" ] && return 1

  runid=$(qstat -f|grep  "$name$" -B1|sed 1q | awk -F[:.] '{print $2}'|sed 's/ //g')
  [[ "$runid" =~ ^[0-9]+$ ]] && echo $runid && return 0

  # we have many matching
  [ -n "$runid" ] && echo "$name in que but not expect: $runid" >&2

  # either way, just do whatever it is again
  return 1
}

## USAGE: ppt1 luna_id 
## start or return queue id of mprage
# if mprage already exists
#  ppt1_pbs.bash will exit succesfully without redoing 
function ppt1 {
  ld=$1;
  name="${ld}_T1"

  dir="$subjroot/$ld/mprage"
  [ ! -d "$dir" ] && echo "bad $ld, no $dir" && return 1

  # check if its running
  # and return id if it is
  getid "$name" || qsub ppt1_pbs.bash -N "$name" -v T1PATH="$dir"  
}

## USAGE: ppt2 luna_id {1..4}
function ppt2 {
  [ -z "$1" -o -z "$2" ] && error "ppt2: empty ld or bn"
  ld=$1;
  bn=$2;
  mid=$3;
  name="${ld}_bars_$bn"

  dir="$subjroot/$ld/bars_$bn"
  [ ! -d "$dir" ] && echo "bad $ld $bn, no $dir" && return 1

  # do we have a mid
  [ -z "$mid" ] && mid=$(ppt1 $ld) 
  getid "$name" >/dev/null || 
    qsub ppt2_pbs.bash -N "$name" -W depend=afterok:$mid -v T2PATH="$dir"  

}

for sdir in ../subj/*; do
  ld=$(basename $sdir)
  # get mprage id 
  mid=$(ppt1 $ld)

  # run for each block
  for bn in {1..4}; do
    if [ ! -r $sdir/bars_$bn/.preprocessfunctional_complete ]; then
      ppt2 $ld $bn $mid || echo "$ld $bn: missing files?"
    fi
  done

done

