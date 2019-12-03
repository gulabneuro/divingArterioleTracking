%takes an image and smooths it with the given kernel via convolution
%
%inputs:
%im = image to be processed
%kerntype is either the actual kernel to be used or the name of it 
%kernsz is a 2 element array with the first element being the size of hte
%kernel (has to be squaare and odd) and the second # is the width which
%would be used for the gaussian kernel


function r = L_convolve(im,kerntype,kernsz)

dopadding = 1;
if nargin < 3
    kernsz = 5;
    w = kernsz/4;
else
    w  = kernsz(2);
    kernsz = kernsz(1);
end
[M,N] = size(im);

%pad image to reduce edge effects:
if dopadding
    padim = -ones(size(im,1)+kernsz*2,size(im,2)+kernsz*2);
    padim((kernsz+1):(kernsz+M),(kernsz+1):(kernsz+N)) = im;

    padim((kernsz+1):(kernsz+M),1:kernsz) = repmat(im(:,1),1,kernsz);
    padim((kernsz+1):(kernsz+M),(kernsz+1+N):end) = repmat(im(:,1),1,kernsz);
    padim(1:kernsz,(kernsz+1):(kernsz+N)) = repmat(im(1,:),kernsz,1);
    padim((kernsz+1+M):end,(kernsz+1):(kernsz+N)) = repmat(im(1,:),kernsz,1);
    padim(padim==-1) = prctile(im(:),5);%min(im(:));
else
    padim = im;
end

%generate kernels
if ~ischar(kerntype)
    kern = kerntype;
else
    if strcmp(kerntype, 'uniform')
        %% circular:
        [X,Y] = meshgrid(1:kernsz(1),1:kernsz(1));
        X = X - mean(1:kernsz(1)); Y = Y - mean(1:kernsz(1));
        Z = sqrt(X.^2 + Y.^2);
        kern = zeros(size(Z));
        kern(Z<(kernsz(1)/2)) = 1;
        %% square
        %kern = ones(kernsz);
        kern = kern/sum(kern(:));
    elseif strcmp(kerntype, 'gaussian')
        kern = fspecial('gaussian',kernsz,w);
    elseif strcmp(kerntype,'mexihat')
        [X,Y] = meshgrid(1:kernsz,1:kernsz);
        X = X-ceil(kernsz/2);Y = Y-ceil(kernsz/2);
        kern = (1/(pi*w^2))*(1-.5*(X.^2+Y.^2)/(w^2)).*exp(-.5*((X.^2 + Y.^2)/(w^2)));
        kern = kern/sum(kern(:));
    elseif strcmp(kerntype, 'sharp')
        kern = -ones(kernsz);
        kern(ceil((kernsz^2)/2)) = numel(kern);
    end
end

%perform convolution
r = conv2(padim,kern,'same');
%temp = conv2(padim,kern,'same');
r = r((kernsz+1):(kernsz+M),(kernsz+1):(kernsz+N));


