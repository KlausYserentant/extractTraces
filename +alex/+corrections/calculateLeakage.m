function l = calculateLeakage(greenExGreenEm, greenExRedEm)
% calculate the leakage coefficient l from a trace for D species
    
    l = greenExRedEm ./ ...
            greenExGreenEm;
end