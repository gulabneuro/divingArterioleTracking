
%function calculates the objective function for ellipse fitting

function r = evalEllipseFit2(ellipse,ridgepoints)


r = zeros(size(ridgepoints,1),1);
for n = 1:size(ridgepoints,1)
    %r(n) = point2ellipseDist(ridgepoints(n,:),ellipse);
    r(n) = point2ellipseDist2(ridgepoints(n,:),ellipse);
end


