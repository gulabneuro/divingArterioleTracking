
%input parameters:
%mov is a MxNxnumFrames array of the movie being tracked
%doplot is set to 1 if you want to display the tracking live (default is 0)
%prefit is done if you want to include already fit parameters (for display
%only)
%intenThresh is the intensity threshold used to generated the binarized
%image; if this is left empty then the algorithm will try to detect a
%threshold automatically (do not recommend)
%islumen is a sentinel variable indicating if the movie is of a
%lumen-filled vessel (e.g. QDs) or of the edge of the vessel (e.g.
%hydrzide), default is 0

function [r,params,ridgeindices,imsz] = fitEllipseRidgeMovie(ridgeMovie,doplot,mov)

imsz = size(ridgeMovie);
if length(imsz) == 3
    nf = imsz(3);
else
    nf = 1;
end
if nargin < 2 || isempty(doplot)
    doplot = 0;
end

if doplot
    figa = figure;
    set(figa, 'position',[2655 ,  318 ,  1356 ,844]);
    figb = figure;
    set(figb, 'position',[4054 , 476,  705 , 535]);
end

p1 = nan(nf,6);
p2 = nan(nf,6);
p3 = nan(nf,6);

ridgeindices = [];
tic;
for m = 1:nf
    curim = ridgeMovie(:,:,m);
    [ellipseFit,r] = fitellipse5(curim);
    ind = find(curim > 1);
    ridgeindices = nancat(ridgeindices,ind,2);
    p1(m,:) = ellipseFit(1,:);
    p2(m,:) = ellipseFit(2,:);
    p3(m,:) = ellipseFit(3,:);
    if doplot
        figure(figa)
        subplot(1,2,1)
        hold off
        imagesc(curim)
        hold on
        [M,N] = ind2sub(size(ridgeim),ind);
        plot(N,M,'r.')
        subplot(1,2,2)
        hold off
        imagesc(r)
        hold on
        plot(N,M,'r.')
        pause(.01)
        figure(figb)
        plot(p1(:,3).*p1(:,4)*pi,'r.')
        hold on
        plot(p2(:,3).*p2(:,4)*pi,'g.')
        plot(p3(:,3).*p3(:,4)*pi,'b.')
        hold off
    end
end
toc
params = cat(3,p1,p2,p3);
im = ridgeMovie(:,:,1);
[r,r2] = weightedEllipseAverage(params,ridgeindices,size(im));
if doplot
    figure
    plot(r,'b.')
    hold on
    plot(r2,'r.')
    plot(smooth(r),'b')
end