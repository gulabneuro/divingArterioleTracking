

function t = pickThreshold(im)

figure
set(gcf,'position',[2712,248,1572,1066]);
satisfied = 0;

while satisfied == 0
    subplot(1,2,1)
    mesh(im)
    t = input('set a threshold value');
    subplot(1,2,2)
    filtim = im;
    filtim(im<t) = nan;
    mesh(filtim)
    satisfied = input('does this value work [1/0]?');
    if satisfied < 0
        t = [];
        break;
    end
end


