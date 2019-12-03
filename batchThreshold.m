
%to be used after batchSmoothWrite; this takes into account saved
%thresholds

function batchThreshold(manualThresholdsFilename,convertTo8bit)

if ~isempty(manualThresholdsFilename)
    load(manualThresholdsFilename);
else
    avlength = input('what is the length of temporal averaging in frames? ');
    movpath = cd;
    temp = dir('*smoothed.tif');
    movname = cell(size(temp));
    for n = 1:length(temp)
        movname{n} = temp(n).name;
    end
    nummovies = length(movname);
    islumen = zeros(nummovies,1);
    intenThresh = zeros(1,nummovies);
    for n = 1:nummovies
        cd(movpath)
        startframe = 180;
        
        im = loadTiffStack(movname{n},startframe);
        while true
            try
                intenThresh(n) = pickThreshold(im);
                break;
            catch
                disp('invalid entry')
            end
        end
            
        disp(movname{n});
        while true
            try 
                islumen(n) = input('is this a lumen-fill movie? [1/0]: ');
                break;
            catch
                disp('invalid entry')
            end
        end
                
    end
    %% save the thresholds you set manually for possible future use:
    save('manualThresholds.mat','movname','intenThresh','avlength','islumen');
end

%options for tiff stack writing
options.compress = 'no';
options.color = false;
options.message = false;
options.append = true;

if nargin < 2 || isempty(convertTo8bit)
    convertTo8bit = 0;
end

nummovies = length(movname);

movnameSuffix = ['_',num2str(avlength),'frameAvg_smoothed.tif'];
medianMovieSuffix = ['_',num2str(avlength),'frameAvg_smoothed.tif'];
for n = 1:nummovies
    curname = strrep(movname{n},'.tif',movnameSuffix);
    curmedian = strrep(curname,movnameSuffix,'_medianIm.tif');
    try
        mov = loadTiffStack(curname);
        if isfile(curmedian)
            medim = loadTiffStack(curmedian);
        end  
    catch
        curname = movname{n};
        curmedian = strrep(curname,movnameSuffix,'_medianIm.tif');
        try
            mov = loadTiffStack(curname);
            if isfile(curmedian)
                medim = loadTiffStack(curmedian);
            end  
            disp('defaulting to no suffix added');
        catch
            disp('failed to find appropriate movie');
            continue;
        end
    end
    
    
    mov(mov<intenThresh(n)) = intenThresh(n);
    savename = strrep(curname,'_smoothed','_thresholded_smoothed');
    if exist('medim')
        medim(medim<intenThresh(n)) = intenThresh(n);
        savenameMed = strrep(curmedian,'median','thresholded_median');
    end

    if convertTo8bit == 1
        mov = mbatov-intenThresh(n);
        mov = mov./max(mov(:))*255;
        mov = uint8(mov);
        if exist('medim')
            medim = uint8(medim./max(medim(:))*255);
        end
    elseif max(mov(:)) < 256
        mov = uint8(mov);
        if exist('medim')
            medim = uint8(medim);
        end
    else
        mov = uint16(mov);
        if exist('medim')
            medim = uint16(medim);
        end
    end
    saveastiff(mov,savename,options);
    if exist('medim')
        saveastiff(medim,savenameMed,options);
    end
    disp(n/nummovies)
end