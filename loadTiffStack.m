

function mov = loadTiffStack(filename,framerange)

temp = imfinfo(filename);
mov = zeros(temp(1).Height,temp(1).Width,length(temp));
if nargin > 1 && ~isempty(framerange)
    mov = mov(:,:,1:numel(framerange));
else
    framerange = 1:size(mov,3);
end
%for n = framerange
%    mov(:,:,n) = imread(filename,'ind',n);
%end

for n = 1:numel(framerange)
    mov(:,:,n) = imread(filename,'ind',framerange(n));
end