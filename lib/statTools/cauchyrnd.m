function r = cauchyrnd(n,location,scale,boundary)
    runif = rand(1,n);
    r = location+scale*tan(pi*(runif-0.5));
    while sum(abs(r-location)>boundary)>0
        invalid = abs(r-location)>boundary;
        r(invalid) = location+scale*tan(pi*(rand(1,sum(invalid))-0.5));
    end
end