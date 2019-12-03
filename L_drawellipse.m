

function [x,y] = L_drawellipse(ellipseparams)

a = ellipseparams(1);
b = ellipseparams(2);
xo = ellipseparams(3);
yo = ellipseparams(4);
theta = ellipseparams(5);
alpha = linspace(0,2*pi,100);
x = a*cos(alpha)*cos(theta) - b*sin(alpha)*sin(theta) + xo;
y = a*cos(alpha)*sin(theta) + b*sin(alpha)*cos(theta) + yo;