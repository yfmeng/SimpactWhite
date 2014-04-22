function r = normrnd(mu,sigma,m,n)
r = randn(m,n) .* sigma + mu;
end
