

%code for converting ellipse parameters into other standards:

if 1
    %let user select the files
    [fn,pn] = uigetfile('*refinedFit.mat','multiselect','on');
else
    %alternatively, automatically load all the refinedFit.mat files:
    temp = dir('*refinedFit.mat');
    fn = cell(1,length(temp));
    for n = 1:length(temp)
        fn{n} = temp(n).name;
    end
    pn = cd;
end

cd(pn)
if ischar(fn)
    temp = fn;
    fn = cell(1);
    fn{1} = temp;
end
qualityThreshold = .5;          %if greater than this fraction of points in a trace are bad, then throw out the trace?
minaxErrorThresh = 4;           %if the confidence interval on the minor axis is beyond this then count it as a bad #
%minaxErrorThresh = .2;         %this would express the error threshold as a fraction of the actual radius 
smoothedArea = [];
diameter = [];
ddd = [];
cd(pn)
for n = 1:length(fn)
    load(fn{n})
    temp = refinedFit(:,1:2);
    temp(:,2) = temp(:,1).*temp(:,2);
    ab = sort(temp,2);
    minoraxis = ab(:,1);
    try
        er = diff(confidenceIntervals,1,3);
        er(:,2) = temp(:,1).*er(:,2);
        minaxError = min(er(:,1:2),[],2);
    catch
        disp('confidence interval unavailable');
        er = zeros(size(refinedFit));
        minaxError = min(er(:,1:2),[],2);
    end
    
    %filtering step to reduce poorly fit points, outliers:
    %initfitname = strrep(fn{n},'refined','initial');
    %load(initfitname,'params');
    %ellipsescore = max(params(:,6,:),[],3);
    %ellipseScoreThresh = 12;
    %minoraxis(ellipsescore < ellipseScoreThresh) = nan;
    
    i1 = find(minaxError > minaxErrorThresh);
    minoraxis(i1) = nan;
    i1 = isoutlier(ab(:,1),'movmedian',10,'ThresholdFactor',2);
    minoraxis(i1 == 1) = nan;
    i2 = isoutlier(minoraxis,'movmedian',10,'ThresholdFactor',2);
    minoraxis(i2 == 1) = nan;
    
    
    %this way calculates the diameter from the total area
    A = pi*refinedFit(:,1).*(refinedFit(:,1).*refinedFit(:,2));
    try
    sa = smooth(A,'rlowess');
    catch
        'a'
    end
    smoothedArea = [smoothedArea,sa];
    d = sqrt(sa/pi)*2;
    
    d(isnan(minoraxis)) = nan;
    diameter = [diameter,d];         %D
    d = d/mean(d(120:150));
    %ddd = [ddd,d/mean(d(120:150))];     %deltaD/D
    
    %this way calculates diameter from just the minor axis
    d = smooth(minoraxis,'rlowess')*2;
    d = d/mean(d(120:150));
    %d(isnan(minoraxis)) = nan;
    if sum(isnan(minoraxis))/numel(minoraxis) > qualityThreshold
        d(:) = nan;
        %d(isnan(minoraxis)) = nan;
    end 
    d(isnan(minoraxis)) = nan;
    ddd = [ddd,d];
end
if exist('valids')
    [allTrials,technicalRepeatAveraged] = ddd_to_cells(fn,ddd,valids);
else
    [allTrials,technicalRepeatAveraged] = ddd_to_cells(fn,ddd);
end
for n = 1:numel(allTrials)
    if isnan(allTrials{n})
        allTrials{n} = 'NaN';
    end
end
for n = 1:numel(technicalRepeatAveraged)
    if isnan(technicalRepeatAveraged{n})
        technicalRepeatAveraged{n} = 'NaN';
    end
end

if 0
    writecell(allTrials,'DeltaDoverD-allTraces.xlsx');
    writecell(technicalRepeatAveraged,'DeltaDoverD-technicalRepeatAveraged.xlsx');
end
figure
plot(ddd,'.')
hold on
plot(nanmean(ddd,2),'k','linewidth',2)

figure
b1 = reshape(technicalRepeatAveraged(:,1,:),[301,5]);
b2 = reshape(technicalRepeatAveraged(:,2,:),[301,5]);
b3 = reshape(technicalRepeatAveraged(:,3,:),[301,5]);
b4 = reshape(technicalRepeatAveraged(:,4,:),[301,5]);
b5 = reshape(technicalRepeatAveraged(:,5,:),[301,5]);
poolbin = cat(3,b1(2:end,:),b2(2:end,:),b3(2:end,:),b4(2:end,:),b5(2:end,:));
for n = 1:numel(poolbin)
    if ischar(poolbin{n}) || isempty(poolbin{n})
        poolbin{n} = nan;
    end
end
poolbin = cell2mat(poolbin);
x = (1:300)*.1;
clrorder = 'brgmk';
for n = 1:5
    y = nanmean(poolbin(:,:,n),2);
    ys = nanstd(poolbin(:,:,n),[],2);
    %plot(x,y,clrorder(n),'displayname',['bin ',num2str(n)])
    %shadedErrorBar(x,y,ys,clrorder(n),1)
    plot(x,y,[clrorder(n),'.'],'displayname',['bin ',num2str(n)])
    hold on
end
