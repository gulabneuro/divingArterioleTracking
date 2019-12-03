

numfields = 4
numbins = 3
results = [];
for n = 1:numfields
    for m = 1:numbins
        curname = ['*fov',num2str(n),'*bin',num2str(m+1),'*refinedFit.mat'];
        nm = dir(curname);
        smoothedArea = [];
        diameter = [];
        ddd = [];
        for k = 1:length(nm)
            try
                load(nm(k).name)
            catch
                disp('could not find data')
                continue;
            end
            temp = refinedFit(:,1:2);
            temp(:,2) = temp(:,1).*temp(:,2);
            ab = sort(temp,2);
            minoraxis = ab(:,1);
            
            %get diameter from area:
            A = pi*refinedFit(:,1).*(refinedFit(:,1).*refinedFit(:,2));
            sa = smooth(A,'rlowess');
            smoothedArea = [smoothedArea,sa];
            d = sqrt(sa/pi)*2;
            diameter = [diameter,sqrt(sa/pi)*2];         %D
            %ddd = [ddd,d/mean(d(120:150))];     %deltaD/D
            
            %get diameter from minor axis only (this is a bit more stable
            %with poorer quality data):
            d = smooth(minoraxis,'rlowess')*2;
            ddd = [ddd,d/mean(d(120:150))];
        end
        ddd = mean(ddd,2);
        temp = cell(numel(ddd)+1,1);
        temp{1} = ['fov',num2str(n),'-bin',num2str(m)];
        for k = 1:length(ddd)
            temp{k+1} = ddd(k);
        end
        if ~isempty(k)
            results = [results,temp];
        end
    end
end
writecell(results,'meanDeltaDoverD.xlsx');
