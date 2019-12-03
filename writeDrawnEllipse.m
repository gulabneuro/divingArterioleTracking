


%bit of script to write a tif stack of the drawn ellipse
function writeDrawnEllipse(refinedTrackingName)


%options for tiff stack writing
options.compress = 'no';
options.color = false;
options.message = false;
options.append = true;


load(strrep(refinedTrackingName,'refined','initial'));
load(refinedTrackingName)
numframe = size(refinedFit,1);
writename = strrep(refinedTrackingName,'.mat','_fit.tif');
ellipseMovie = zeros(imsz);
for n = 1:numframe
    temp = refinedFit(n,:);
    temp(2) = temp(1)*temp(2);
    [x,y] = L_drawellipse(temp);
    im = zeros(imsz(1:2));
    if isnan(x(1))
        ellipseMovie(:,:,n) = im;
        continue;
    end
    x = round(x); y = round(y);
    i1 = find(x>0);i2 = find(y>0); i1 = intersect(i1,i2);
    i11 = find(x<imsz(2)); i22 = find(y<imsz(1)); i2 = intersect(i11,i22);
    ind = intersect(i1,i2); x=x(ind);y=y(ind);

    ind = sub2ind(imsz(1:2),y,x);

    im(ind) = 100;
    ellipseMovie(:,:,n) = im;
    %im = uint16(im);
    %imwrite(im,writename,'tif','writemode','append','compression','none')
end

ellipseMovie = uint16(ellipseMovie);
saveastiff(ellipseMovie,writename,options);


