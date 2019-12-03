
%function finds the shortest distance between any point in the cartesian
%plane and a point on the given ellipse
function [d,ellipsePt] = point2ellipseDist2(pt,ellipse)

%alternative parameterization: all parameters except "b" are the same from point2ellipseDist;
%instead b is given as an aspect ratio parameter, so instead of just using
%it you have to multiply it by a:
a = ellipse(1);
b = ellipse(2)*a;
xo = ellipse(3);
yo = ellipse(4);
theta = ellipse(5);

Fx = @(alpha) a*cos(alpha)*cos(theta) - b*sin(alpha)*sin(theta) + xo;
Fy = @(alpha) a*cos(alpha)*sin(theta) + b*sin(alpha)*cos(theta) + yo;

D = @(alpha) sqrt((Fx(alpha)-pt(1))^2 + (Fy(alpha)-pt(2))^2);

%minalpha = fminsearch(D,0);
minalpha = fminbnd(D,0,2*pi);

d = D(minalpha);
ellipsePt = [Fx(minalpha),Fy(minalpha)];

if 0
    figure
    temp = linspace(0,2*pi,200);
    plot(Fx(temp),Fy(temp))
    hold on
    plot(pt(1),pt(2),'ro')
    plot(ellipsePt(1),ellipsePt(2),'go')
    hold off
    axis equal
end