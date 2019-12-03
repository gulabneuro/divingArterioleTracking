

inputdir = "D:\\Luke\\divingArterioleTracking\\6884\\S3\\thresholded\\temp\\";
outputdir = inputdir;
list = getFileList(inputdir);
setBatchMode(true);
for (i = 0; i < list.length; i++) {
	if (endsWith(list[i],".tif")) {
		if (endsWith(list[i],"medianIm.tif")) {
			open(inputdir+list[i]);
			saveName = getTitle();
			saveName = replace(saveName,"medianIm","medianIm-ridge");
		
			saveName = outputdir+saveName;
			
			run("Ridge Detection", "line_width=3.5 high_contrast=230 low_contrast=87 correct_position extend_line make_binary method_for_overlap_resolution=NONE sigma=2 lower_threshold=0.40 upper_threshold=2 minimum_line_length=10 maximum=0");
			saveAs("Tiff",saveName);
			run("Close All");
		} else {
			open(inputdir+list[i]);
			saveName = getTitle();
			saveName = replace(saveName,".tif","_ridge.tif");
		
			saveName = outputdir+saveName;
			
			sn1 = replace(saveName,".tif","_1.tif");
			sn2 = replace(saveName,".tif","_2.tif");
			sn3 = replace(saveName,".tif","_3.tif");
			sn4 = replace(saveName,".tif","_4.tif");
		
			
			run("Ridge Detection", "line_width=3.5 high_contrast=230 low_contrast=87 correct_position extend_line make_binary method_for_overlap_resolution=NONE sigma=1 lower_threshold=0.40 upper_threshold=4 minimum_line_length=10 maximum=0 stack");
			saveAs("Tiff",sn1);
			run("Close");
			run("Ridge Detection", "line_width=3.5 high_contrast=230 low_contrast=87 correct_position extend_line make_binary method_for_overlap_resolution=NONE sigma=2 lower_threshold=0.40 upper_threshold=4 minimum_line_length=10 maximum=0 stack");
			
			saveAs("Tiff",sn2);
			run("Close");
			run("Ridge Detection", "line_width=3.5 high_contrast=230 low_contrast=87 correct_position extend_line make_binary method_for_overlap_resolution=NONE sigma=3 lower_threshold=0.40 upper_threshold=4 minimum_line_length=10 maximum=0 stack");
			saveAs("Tiff",sn3);
			run("Close");
		
			run("Ridge Detection", "line_width=3.5 high_contrast=230 low_contrast=87 correct_position extend_line make_binary method_for_overlap_resolution=NONE sigma=0.80 lower_threshold=0.20 upper_threshold=2 minimum_line_length=10 maximum=0 stack");
			saveAs("Tiff",sn4);
			run("Close All");
		}
	}

	
}
setBatchMode(false);