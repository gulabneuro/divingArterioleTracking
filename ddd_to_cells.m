
%fn is the filenames of the tracking files
%ddd is the normalized deltaD/D
%valids is an optional parameter, saying which traces you'd like to
%actually use; defaults to all of them
function [allTrials,technicalRepeatAveraged] = ddd_to_cells(fn,ddd,valids)

numtraces = size(ddd,2);
numframes = size(ddd,1);
if nargin >2 &&~isempty(valids)
    ind = 1:numtraces;
    ind = setdiff(ind,valids);
    ddd(:,ind) = nan;
end

tracking = cell(size(ddd,1)+1,numtraces);
for n = 1:numtraces
    tracking(2:end,n) = num2cell(ddd(:,n));
    nm = fn{n};
    i1 = strfind(nm,'fov');
    i2 = strfind(nm,'bin');
    tracking{1,n} = ['fov ',nm(i1+3),' bin ',nm(i2+3)];
end

identity = zeros(2,numtraces);  %top row is fov, bottom row is bin#
for n = 1:numtraces
    identity(1,n) = str2double(tracking{1,n}(5));
    identity(2,n) = str2double(tracking{1,n}(end));
end
r = nan(numframes,5,5);     %collecting the results; the 3rd dimension is fov#, each column is a bin#; averaging over technical trials
technicalRepeatAveraged = cell(numframes+1,5,5);
%averaging technical repeats
for n = 1:5
    fovind = find(identity(1,:) == n);
    for n2 = 1:5
        binind = find(identity(2,:) == n2);
        if isempty(binind) || isempty(fovind)
            continue;
        end
        ind = intersect(fovind,binind);
        
        %deletes any frame where not all 3 trials are present
        %cur = mean(ddd(:,ind),2);
        
        cur = nanmean(ddd(:,ind),2);
        r(:,n2,n) = cur;
        cellind = ((n-1)*5+n2);
        technicalRepeatAveraged{1,cellind} = ['fov ',num2str(n),' bin ',num2str(n2)];
        technicalRepeatAveraged(2:end,cellind) = num2cell(cur);
    end
end
allTrials = tracking;







    