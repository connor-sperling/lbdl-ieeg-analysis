function [r, g, b] = rgb_grad(r, g, b, rinit, ginit, binit, size)
  
    rr = .6*floor(rinit/size)/255;
    gr = .7*floor(ginit/size)/255;
    br = .25*floor(binit/size)/255;

%     if r == 1 && g == 1
%         binit = binit + 30;
%         br = binit;
%     else
%         br = 0;
%     end
    
    if (r - rr) <= 1 && (r - rr) >= 0
        r = (r - rr);
    else
        r = 0;
    end

    if (g - gr) <= 1 && (g - gr) >= 0
        g = (g - gr);
    else
        g = 0;
    end

    if (b - br) <= 1 && (b - br) >= 0
        b = (b - br);
    else
        b = 0;
    end

    
    % To reverse colors, need to make rbg decrease quadratically
    c1 = [rst gst bst];
    c2 = [188 186 121];
    c3 = [122 121 79];
    plot(1:3, c1, 1:3, c2, 1:3, c3)
    
end