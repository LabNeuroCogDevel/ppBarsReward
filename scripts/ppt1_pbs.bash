#!/usr/bin/env bash
#PBS -l ncpus=4
#PBS -o logs/$PBS_JOBNAME.$PBS_JOBID.log
#PBS -e logs/$PBS_JOBNAME.$PBS_JOBID.err
source /data/Luna1/ni_tools/ni_path_plus.bash

# bash settings and functions
#  error, 
source /data/Luna1/ni_tools/bash_funcs_src.bash



# need to know where to look
# /raid/r5/p1/Luna/Bars/subj/$LUNADATE/mprage
[   -z "$T1PATH" ] && error "need T1PATH to be defined" 
[ ! -d "$T1PATH" ] && error "need T1PATH ($T1PATH) to be a directory" 

[ -r $T1PATH/mprage_final.nii.gz ] && echo "$T1PATH/mprage_final.nii.gz already exists" && exit 0

## are we going to use mprage.nii.gz
## or MR*
cd $T1PATH
if [ -r mprage.nii.gz ]; then 
 input="-n mprage.nii.gz"
else
 nMR=$(ls MR* 2>/dev/null|wc -l)
 [ $nMR -ne 176 ] && error "$T1PATH should have 176 MR files!"
 ## NEVERMIND -- Dimon is finicky? use dcm2nii
 #input="-p 'MR*'"


 d2ncmd="dcm2nii -p n -i n -e n -a n -r n -x n MR*"
 eval "$d2ncmd"

 d2nf=$(ls -tcr *nii.gz 2>/dev/null |sed 1q)
 [[ -z "$d2nf" || $d2nf =~ [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*.nii.gz ]] && 
   error "couldn't find a the right initial mprage file ($d2nf)"

 mv $d2nf mprage.nii.gz
 # not here: fslorient strips the notes out
 # 3dNotes -h "$d2ncmd" mprage.nii.gz

 input="-n mprage.nii.gz"

 # remove the linked MR*
 # ...make sure we are removing the link :)
 find . -maxdepth 1 -type l -name 'MR*' -exec rm "{}" +
fi


cmd="preprocessMprage -r MNI_2mm -o mprage_final.nii.gz -cleanup -d yes $input "

# run and record history
eval $cmd

3dNotes -h "$d2ncmd" mprage.nii.gz
3dNotes -h "$cmd" mprage_final.nii.gz

