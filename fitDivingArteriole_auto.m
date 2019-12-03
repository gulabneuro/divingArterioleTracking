

%to run this, have to have the ridge movies already saved; you can do this
%automatically using batchSmoothWrite.m to smooth the appropriate movies in
%a specific SEPARATE directory, then in FIJI run the macro autoRidgeDetect.ijm on
%that whole directory, then can run this code (it relies on stereotyped
%image names...)


%% load appropriate movie(s)
if 0                %this option allows manual selection of the movies to be fit
    [movname,movpath] = uigetfile('*smoothed.tif','select movie','multiselect','on');
    if ischar(movname)
        temp = movname;
        movname = cell(1);
        movname{1} = temp;
    end
else                %this  block automatically fits all the movies in the directory
    movpath = cd;
    temp = dir('*smoothed.tif');
    movname = cell(size(temp));
    for n = 1:length(temp)
        movname{n} = temp(n).name;
    end
end
nummovies = length(movname);
    
%% perform initial fitting using elliptical hough transform:
for n = 1:nummovies
    cd(movpath)
    ridgename = strrep(movname{n},'.tif','_ridge.tif');
    
    mov = loadTiffStack(ridgename);
    
    
    %this option is the one withOUT live visualization of the tracking
    [areaEstimate, params, ridgeindices,imsz] = fitEllipseRidgeMovie(mov,0);       
    
    %this option is the one with live visualization of the tracking
    %[areaEstimate, params, ridgeindices,imsz] = fitEllipseMovie(mov,1,[],intenThresh(n),islumen(n));
    
    initialEstimateName = strrep(movname{n},'.tif','_initialFit.mat');
    
    %% if a median image is available in the directory, fit that one to use as input lower/upper bounds for subsequent images
    try
        temp = strfind(movname{n},'frameAvg');
        
        ridgename = [movname{n}(1:(temp-2)),'thresholded_medianIm-ridge.tif'];
        
        mov = loadTiffStack(ridgename);
        [~, params0, ridgeindices0,imsz0] = fitEllipseRidgeMovie(mov,0);
        [refinedFit,confidenceIntervals] = refineHoughEllipse(params0,ridgeindices0,imsz0);
        bounds = reshape(confidenceIntervals,[5,2])';
        bounds(1,1:2) = bounds(1,1:2)*.6;
        bounds(2,1:2) = bounds(2,1:2)*2;
        bounds(:,3:4) = nan;
        bounds(1,5) = bounds(1,5)*.8;
        bounds(2,5) = bounds(2,5)*1.2;
    catch
        bounds = [];
    end
    save(initialEstimateName,'areaEstimate','params','ridgeindices','imsz','bounds')
end



    

%% refine initial fits by minimizing distance from ridge points to ellipse
for n = 1:nummovies
    clear params ridgeindices imsz currentMovieName
    cd(movpath)
    
    curname = strrep(movname{n},'.tif','_initialFit.mat');
    
    load(curname);
    [refinedFit,confidenceIntervals] = refineHoughEllipse(params,ridgeindices,imsz,bounds);
    refineSaveName = strrep(curname,'initialFit','refinedFit');
    
    currentMovieName = movname{n};
    
    save(refineSaveName,'refinedFit','movpath','currentMovieName','confidenceIntervals')
    if 0
        figure
        A = pi*refinedFit(:,1).*(refinedFit(:,1).*refinedFit(:,2));
        plot(smooth(A,'rlowess'))
        title(movname{n})
    end
end 

%% block of code for checking how the any individual fit looks:
if 0
    movnum = 1;
    cd(movpath)
    mov = loadTiffStack(movname{movnum});
    load(strrep(movname{movnum},'.tif','_refinedFit.mat'));
    %load(strrep(movname{movnum},'.tif','_noAvg_refinedFit.mat'));
    figure
    for n = 1:size(mov,3)
        imagesc(mov(:,:,n))
        hold on
        temp = refinedFit(n,:);
        temp(2) = temp(1)*temp(2);
        [x,y] = L_drawellipse(temp);
        plot(x,y,'w--','linewidth',2)
        axis equal
        title(num2str(n))
        pause(.05)
        hold off
    end
end


%% block writing .tif stacks of the fit ellipse:
if 1
    for n = 1:length(movname)
        
        cur = strrep(movname{n},'.tif','_refinedFit.mat');
        writeDrawnEllipse(cur);
    end
end
        


