#!/bin/bash 
set -e

# function for parsing options
getopt1() {
    sopt="$1"
    shift 1
    for fn in $@ ; do
	if [ `echo $fn | grep -- "^${sopt}=" | wc -w` -gt 0 ] ; then
	    return 0
	fi
    done
}

# parse arguments
WD=`getopt1 "--workingdir" $@`  # "$1"
Input=`getopt1 "--in" $@`  # "$2"
Reference=`getopt1 "--ref" $@`  # "$3"
Output=`getopt1 "--out" $@`  # "$4"
OutputMatrix=`getopt1 "--omat" $@`  # "$5"
BrainSizeOpt=`getopt1 "--brainsize" $@`  # "$6"

# make optional arguments truly optional  (as -b without a following argument would crash robustfov)
if [ X${BrainSizeOpt} != X ] ; then BrainSizeOpt="-b ${BrainSizeOpt}" ; fi
mkdir -p $WD

'''
- Crop the FOV
- Invert the matrix (to get full FOV to ROI)
- Register cropped image to MNI152 (12 DOF)
- Concatenate matrices to get full FOV to MNI
- Get a 6 DOF approximation which does the ACPC alignment (AC, ACPC line, and hemispheric plane)
- Create a resampled image (ACPC aligned) using spline interpolation
'''

${FSLDIR}/bin/robustfov -i "$Input" -m "$WD"/roi2full.mat -r "$WD"/robustroi.nii.gz $BrainSizeOpt
${FSLDIR}/bin/convert_xfm -omat "$WD"/full2roi.mat -inverse "$WD"/roi2full.mat
${FSLDIR}/bin/flirt -interp spline -in "$WD"/robustroi.nii.gz -ref "$Reference" -omat "$WD"/roi2std.mat -out "$WD"/acpc_final.nii.gz -searchrx -30 30 -searchry -30 30 -searchrz -30 30
${FSLDIR}/bin/convert_xfm -omat "$WD"/full2std.mat -concat "$WD"/roi2std.mat "$WD"/full2roi.mat
${FSLDIR}/bin/aff2rigid "$WD"/full2std.mat "$OutputMatrix"
${FSLDIR}/bin/applywarp --rel --interp=spline -i "$Input" -r "$Reference" --premat="$OutputMatrix" -o "$Output"
