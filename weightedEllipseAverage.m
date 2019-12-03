
%params is a numframe x 6 x 3 array of fitting parameters for a movie of a
%vasodilation. There are three possible ellipses for each frame whose
%parameters are given by [x,x,1], [x,x,2], [x,x,3]. 
%Each row of the params array is a separate frame
%first column is x-coordinate of the center;
%second column is y-coordinate of the center;
%third column is the length of the major axis
%fourth column is the length of the minor axis
%fifth column is the angle
%sixth column is the "score" of the fit
function [r,r2] = weightedEllipseAverage(params,ridgeind,imsz)


numframe = size(params,1);
r = nan(numframe,1);          %this will be the area

for n = 1:numframe
    curridge = ridgeind(:,n);
    curridge = curridge(~isnan(curridge));
    matchedpoints = [0,0,0];
    if isnan(params(n,1,1))
        continue;
    end
    for k = 1:3
        p = [params(n,3,k),params(n,4,k),params(n,1,k),...
            params(n,2,k),params(n,5,k),1,1,0];
        curellipse = makeellipse(p,imsz);
        bw = find(curellipse>.3);
        temp = intersect(curridge,bw);
        matchedpoints(k) = numel(temp);
    end
    [~,bestFit] = max(matchedpoints);bestFit = bestFit(1);
    r(n) = params(n,3,bestFit)*params(n,4,bestFit)*pi;
end


r2 = zeros(size(r));
scoreThresh = 10;
for n = 1:numframe
    curscore = params(n,6,:);curscore = curscore(:);
    curscore(curscore<scoreThresh) = nan;
    totalScore = nansum(curscore);
    for k = 1:3
        if isnan(curscore(k))
            continue;
        end
        r2(n) = r2(n) + params(n,3,k)*params(n,4,k)*pi * (params(n,6,k)/totalScore);
    end
end
r2(r2==0) = nan;

    
    