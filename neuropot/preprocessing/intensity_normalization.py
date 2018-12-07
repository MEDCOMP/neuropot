import subprocess
from __future__ import print_function
import SimpleITK as sitk
import sys
import os

def n4_normalization(*args):
	if len(argv) < 2:
	    print("Incomplete arguments set for N4 normalization, exiting!")
	    exit ( 1 )

	inputImage = sitk.ReadImage( argv[1] )

	if len ( argv ) > 4:
	    maskImage = sitk.ReadImage( argv[4] )
	else:
	    maskImage = sitk.OtsuThreshold( inputImage, 0, 1, 200 )

	if len ( argv ) > 3:
	    inputImage = sitk.Shrink( inputImage, [ int(argv[3]) ] * inputImage.GetDimension() )
	    maskImage = sitk.Shrink( maskImage, [ int(argv[3]) ] * inputImage.GetDimension() )

	inputImage = sitk.Cast( inputImage, sitk.sitkFloat32 )
	corrector = sitk.N4BiasFieldCorrectionImageFilter();
	numberFittingLevels = 4

	if len ( argv ) > 6:
	    numberFittingLevels = int( argv[6] )

	if len ( argv ) > 5:
	    corrector.SetMaximumNumberOfIterations( [ int( argv[5] ) ] *numberFittingLevels  )

	output = corrector.Execute( inputImage, maskImage )
	sitk.WriteImage( output, argv[2] )