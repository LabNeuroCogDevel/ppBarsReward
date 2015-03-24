# Bars
Chucks `bars` re-preprocessed

## Data

pull raw data from functionals and mprage
paths like
 - `/data/Luna1/Raw/MRCTR/10152_20111123/BarsRewards_AntiX4_384x384.*`
 - `/data/Luna1/Raw/MRCTR/10152_20111123/axial_mprage_256x208.6/`

## Scripts
- organized for running in batch jobs on PBS

`scripts/00_getData.bash` links in dicoms (probaby only needs to be run once)
`scripts/01_functional.bash` runs preproc for T2 (`ppt2_pbs.bash`) depending on T1 (`ppt1_pbs.bash`)

## Testing scripts
```bash
 cd scripts/
 T1PATH="/raid/r5/p1/Luna/Bars/subj/10152_20111123/mprage/" ./ppt1_pbs.bash
 T2PATH="/raid/r5/p1/Luna/Bars/subj/10152_20111123/bars_2"  ./ppt2_pbs.bash
```
