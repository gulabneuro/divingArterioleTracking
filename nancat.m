%concatinates arrays of unequal size by filling in the with NaNs


function r = nancat(a,b,dim)


[m1,n1,p1] = size(a);
[m2,n2,p2] = size(b);

m3 = abs(m1-m2);
n3 = abs(n2-n1);
p3 = abs(p2-p1);

switch dim
    case 1
        if n1>n2
            b = [b,nan(m2,n1-n2)];
        elseif n1<n2
            a = [a,nan(m1,n2-n1)];
        end
    case 2
        if m1>m2
            b = [b;nan(m1-m2,n2)];
        elseif m2>m1
            a = [a;nan(m2-m1,n1)];
        end
end

r = cat(dim,a,b);
