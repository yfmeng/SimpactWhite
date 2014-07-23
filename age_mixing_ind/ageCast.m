function temp = ageCast(gender,n,scale,shape)
%temp
    temp = wblrnd(scale,shape,1,n*3);
    temp = temp(temp<=100);
    temp = temp(randperm(length(temp),n));
end

