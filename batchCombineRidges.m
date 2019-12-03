

%allows for the option of 'goodridge', which is a structure:
%goodridge.moviename where each entry with the corresponding movie name has
%the indices of the ridge movies that are good; excluding the ones that are
%bad 
function batchCombineRidges(pruning,doplot,goodridge)

if nargin < 1 || isempty(pruning)
    pruning = 0;
end
if nargin < 2 || isempty(doplot)
    doplot = 0;
end

%options for tiff stack writing
options.compress = 'no';
options.color = false;
options.message = false;
options.append = true;

fn = dir('*thresholded_smoothed.tif');
nummovies = length(fn);
for n = 1:nummovies
    cur = fn(n).name;
    fullmov = loadTiffStack(cur);
    movsz = size(fullmov);
    %don't bother if there's already a combined ridge movie:
    try
        imread(strrep(cur,'.tif','_ridge.tif'));
        continue;
    catch
        disp('no preexisting combined ridge movie detected')
    end
    try
        m1 = loadTiffStack(strrep(cur,'.tif','_ridge_1.tif'));
        temp = m1;      %make sure the ridge detection worked
        temp(temp==255) = 0;
        if max(temp(:))>0
            m1(:) = 0;
        end
        
    catch
        m1 = [];
    end
    try
        m2 = loadTiffStack(strrep(cur,'.tif','_ridge_2.tif'));
        temp = m2;      %make sure the ridge detection worked
        temp(temp==255) = 0;
        if max(temp(:))>0
            m2(:) = 0;
        end
        
    catch
        m2 = [];
    end
    
    try
        m3 = loadTiffStack(strrep(cur,'.tif','_ridge_3.tif'));
        temp = m3;      %make sure the ridge detection worked
        temp(temp==255) = 0;
        if max(temp(:))>0
            m3(:) = 0;
        end
        
    catch
        m3 = [];
    end
    try
        %imread('someNonsenseImage.tif');
        m4 = loadTiffStack(strrep(cur,'.tif','_ridge_4.tif'));
        temp = m4;      %make sure the ridge detection worked
        temp(temp==255) = 0;
        if max(temp(:))>0
            m4(:) = 0;
        end
        
    catch
        m4 = [];
    end
    if isempty(m1)
        m1 = zeros(movsz);
    end
    if isempty(m2)
        m2 = zeros(movsz);
    end
    if isempty(m3)
        m3 = zeros(movsz);
    end
    if isempty(m4)
        m4 = zeros(movsz);
    end
    mov = m1+m2+m3+m4;
    mov(mov>0) = 1;
    for m = 1:size(mov,3)
        mov(:,:,n) = bwmorph(mov(:,:,n),'skel',Inf);
    end
    if pruning
        try
        prunemov = pruneridges(fullmov,mov);
        catch
            'a;'
        end
    else
        prunemov = mov;
    end
    if doplot
        figure
        set(gcf,'position',[2695,509,1276,587])
        for k = 1:size(mov,3)
            subplot(1,3,1)
            imagesc(fullmov(:,:,k))
            axis equal
            subplot(1,3,2)
            imshow(mov(:,:,k))
            subplot(1,3,3)
            imshow(prunemov(:,:,k))
            title(num2str(k))
            pause(.01)
        end
    end
    mov = uint8(prunemov * 255);
    savename = strrep(cur,'.tif','_ridge.tif');
    saveastiff(mov,savename,options);
    disp(n/nummovies)
end



return;

function r = pruneridges(mov,ridgemov)
numframes = size(mov,3);
r = zeros(size(mov));
for n = 1:numframes
    im = mov(:,:,n);
    %sometimes the ridge movie detects the border for some silly reason:
    curridge = ridgemov(:,:,n);
    curridge(:,1) = 0;curridge(1,:) = 0;curridge(end,:) = 0;curridge(:,end) = 0;
    ind = find(curridge>0);
    
    %r(:,:,n) = ridgedetect3(im,ind);
    r(:,:,n) = ridgedetect3(im,ind,.25);

end
return;


