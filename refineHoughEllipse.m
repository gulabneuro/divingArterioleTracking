
%outputs the ellipse parameterization and the confidence interval
function [r,ci] = refineHoughEllipse(po,ridgeinds,imsz,bounds)

if length(imsz) == 3
    nf = imsz(3);
else
    nf = 1;
end
r = nan(nf,5);
ci = nan(nf,5,2);
%get lower and upper bounds for ellipse size based on the range of initial
%parameters:
if nargin < 4 || isempty(bounds)
    lb = zeros(1,5); ub = lb;
    %temp = po(3:4,:);
    temp = po(:,3:4,:);
    lb(1) = min(temp(:)*.8);
    if lb(1)<0
        lb(1) = 0;
    end
    ub(1) = max(temp(:)*1.25);
    %lb(2) = .5; ub(2) = 2;
    %lb(2) = .9; ub(2) = 1.11;       %more conservative...
    lb(2) = .85; ub(2) = 1.17;       %more conservative...
    
    lb(3) = min(po(:,1))*.8; ub(3) = max(po(:,1))*1.25;
    lb(4) = min(po(:,2))*.8; ub(4) = max(po(:,2))*1.25;
    lb(5) = 0; ub(5) = 2*pi;
    
    temp = po(:,1,:);
    lb(3) = min(temp(:))*.8; ub(3) = max(temp(:))*1.25;
    temp = min(po(:,2,:));
    lb(4) = min(temp(:))*.8; ub(4) = max(temp(:))*1.25;
    lb(5) = -pi; ub(5) = pi;
    
    bounds = [lb;ub];
else
    lb = zeros(1,5); ub = lb;
    lb(3) = min(po(:,1))*.7; ub(3) = max(po(:,1))*1.35;
    lb(4) = min(po(:,2))*.7; ub(4) = max(po(:,2))*1.35;
    bounds(:,3:4) = [lb(3:4);ub(3:4)];
    bounds(1,2) = .85;
    bounds(2,2) = 1.17;
    %bounds(1,5) = -pi;
    %bounds(2,5) = pi;
end

for n = 1:nf
    ind = ridgeinds(:,n);ind = ind(~isnan(ind));
    [yridge,xridge] = ind2sub(imsz(1:2),ind);
    eo = po(n,[3,4,1,2,5],1);eo(5) = deg2rad(eo(5));
    if eo(1)<bounds(1,1) || eo(1) > bounds(2,1)
        eo(1) = (bounds(2,1)-bounds(1,1))/2 + bounds(1,1);
    end
    if eo(2)<bounds(1,2) || eo(2) > bounds(2,2)
        eo(2) = (bounds(2,2)-bounds(1,2))/2 + bounds(1,2);
    end
    if eo(5)<bounds(1,5) || eo(5) > bounds(2,5)
        eo(5) = (bounds(2,5)-bounds(1,5))/2 + bounds(1,5);
    end
    
    
    try
        [params,curci] = optimizeEllipse(eo, [yridge,xridge],bounds);
        r(n,:) = params;
        ci(n,:,1) = curci(:,1); ci(n,:,2) = curci(:,2);
        
        %r(n,:) = optimizeEllipse(eo, [yridge,xridge],bounds);
    catch
        r(n,:) = nan;
        disp('unable to refine')
    end
    disp(n/nf)
end


%testing block:
if 0
    figure
    k = n-1;
    temp = zeros(imsz(1:2));
    bleh = ridgeinds(:,k);bleh = bleh(~isnan(bleh));
    temp(bleh) = 1;
    imagesc(temp)
    [x,y] = drawellipse(r(k,:));
    hold on
    plot(x,y,'g')
    hold off
end