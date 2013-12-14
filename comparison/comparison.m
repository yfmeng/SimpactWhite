if ~isdeployed

    path(path,'lib')
    path(path,'MATLAB')
    path(path,'fei/pre_post_process')
end

for r = 1:10

    multi_run(r)

end