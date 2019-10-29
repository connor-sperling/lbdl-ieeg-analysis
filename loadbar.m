function loadbar(n, sz)

    percent = floor(100*n/sz);
    
    p = floor(100*(n-1)/sz);

    if mod(percent, 10) == 0 && mod(p, 10) ~= 0
        
        msg = sprintf('  %d%% done...', percent);
        disp(msg)
        
    end
    
end