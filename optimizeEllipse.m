
%takes output of fitellipse4 as an initial guess at the ellipse and
%optimizes the fit with the objective function calculated by evalEllipseFit
%important that eo is structured as ['vertical' axis magnitude,
%aspect ratio with relation to 'vertical axis', center x-coordinate, center y-coordinate,
%rotation angle]
function [ef,ci] = optimizeEllipse(eo, ridgeim,bounds)

if size(ridgeim,2)
    yridge = ridgeim(:,1);
    xridge = ridgeim(:,2);
else
    ind = find(ridgeim == 1);
    [yridge,xridge] = ind2sub(size(ridgeim),ind);
end
    

%alternate lb, ub parameters using the aspect ratio based parameterization:
if nargin < 3 || isempty(bounds)
    lb = [9,.5,20,20,0];
    ub = [25,2,60,60,2*pi];
else
    lb = bounds(1,:);
    ub = bounds(2,:);
end

eo2 = eo;
eo2(2) = eo(2)/eo(1);       %convert initial parameter guess to aspect ratio format
if eo2(2) < lb(2)
    eo2(2) = lb(2)+.001;
elseif eo(2) > ub(2)
    eo2(2) = ub(2)-.001;
end

F2 = @(p) evalEllipseFit2(p,[xridge,yridge]);
opts = optimoptions('lsqnonlin','Display','off');
%ef = lsqnonlin(F2,eo2,lb,ub,opts);

[ef,~,resid,~,~,~,J] = lsqnonlin(F2,eo2,lb,ub,opts);
try
    ci = nlparci(ef,resid,'jacobian',J);
catch
    lb(5) = -pi; ub(5) = pi;
    [ef,~,resid,~,~,~,J] = lsqnonlin(F2,eo2,lb,ub,opts);
    ci = nlparci(ef,resid,'jacobian',J);
end


