#!/usr/bin/env bash
# preprocess epi (T2) with MH script

#PBS -l ncpus=4
#PBS -o logs/$PBS_JOBNAME.$PBS_JOBID.log
#PBS -e logs/$PBS_JOBNAME.$PBS_JOBID.err
source /data/Luna1/ni_tools/ni_path_plus.bash

# bash settings and functions
#  error 
source /data/Luna1/ni_tools/bash_funcs_src.bash

finalout="nfswdktm_functional_5.nii.gz"
bet="../mprage/mprage_bet.nii.gz"
warp="../mprage/mprage_warpcoef.nii.gz"
TR=1.5


# need to know where to look
# /raid/r5/p1/Luna/Bars/subj/$LUNADATE/mprage
[   -z "$T2PATH" ] && error "need T2PATH to be defined" 
[ ! -d "$T2PATH" ] && error "need T2PATH ($T2PATH) to be a directory" 

[ -r $T2PATH/$finalout ] && 
  echo "$T2PATH/$finalout already exists" && 
  exit 0

cd $T2PATH

[ ! -r $mprage_bet ]  && error "no mprage bet!? ($T2PATH)"
[ ! -r $mprage_warp ] && error "no mprage warp!? ($T2PATH)"

if [ -r functional.nii.gz ]; then 
 input="-4d functional.nii.gz"
else
 nMR=$(ls MR* 2>/dev/null|wc -l)
 [ $nMR -ne 302 ] && error "$T1PATH should have 302 MR files!"
 #input=" -delete_dicom yes -dicom 'MR*' "
 d2ncmd="dcm2nii -p n -i n -e n -a n -r n -x n MR*"
 eval "$d2ncmd"

 d2nf=$(ls -tcr *nii.gz 2>/dev/null |sed 1q)
 [[ -z "$d2nf" || $d2nf =~ [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*.nii.gz ]] && 
   error "couldn't find the right initial functional file ($d2nf)"

 mv $d2nf functional.nii.gz
 input="-4d functional.nii.gz"

 # remove the linked MR*
 # ...make sure we are removing the link :)
 find . -maxdepth 1 -type l -name 'MR*' -exec rm "{}" +
fi

cmd="preprocessFunctional  \
  $input \
  -tr $TR \
  -mprage_bet $bet -warpcoef $warp  \
  -slice_acquisition interleaved \
  -threshold 98_2  \
  -hp_filter 100  \
  -rescaling_method 10000_globalmedian  \
  -template_brain MNI_2.3mm  \
  -func_struc_dof bbr  \
  -warp_interpolation spline  \
  -constrain_to_template y  \
  -wavelet_despike  \
  -4d_slice_motion \
  -motion_censor fd=0.9,dvars=20 \
  -startover
"

# run and record history
eval "$cmd"
3dNotes -h "$cmd" $finalout

