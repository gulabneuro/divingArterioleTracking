# divingArterioleTracking
this repository contains the scripts needed to fit the diameter of diving arterioles as done in Chow, et al. (2019)

sequence of steps to do for tracking:
1. crop area of interest and save .tif stack into a new directory
	make sure the filename contains the bin# and the FOV# as (binX and fovX; case sensitive)
2. perform smoothing both spatially and temporally by running 'batchSmoothWrite.m'

3. manually set thresholds for each movie by running 'batchThreshold.m'
	this will save the thresholds in a file called 'manualThresholds.mat'
	if the manualThresholds file already exists, it will use it instead of asking for inputs
	it will also write the thresholded movies into the current directory

4. move the thresholded images into a new directory
5. perform ridge detection on those by running 'medianImageRidgeDetect_batch.ijm' as a batch macro in FIJI

6. run fitting using fitDivingArteriole_auto.m in MATLAB to fit all the data
7. to export into a spreadsheet, run averageDivingVesselTracking

