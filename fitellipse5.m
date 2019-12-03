
function [ellipseFit,r] = fitellipse5(ridgeImage)

ridgeim = zeros(size(ridgeImage));
ridgeim(ridgeImage > 0) = 1;


po.minMajorAxis = 8;
po.maxMajorAxis = 60;
po.minAspectRatio = .5;%.70;
ellipseFit = ellipseDetection(ridgeim,po);
r = zeros(size(ridgeImage));
for k = 1:3
    p = [ellipseFit(k,3),ellipseFit(k,4),ellipseFit(k,1),ellipseFit(k,2),ellipseFit(k,5),1,1,0];
    r = r + makeellipse(p,size(ridgeImage));
end
