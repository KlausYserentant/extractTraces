function d = calculateDirectExcitation(greenExRedEm, ...
    redExRedEm)
% calculate the direct excitation coefficient from a trace with A species
    
    d = greenExRedEm ./ ...
            redExRedEm;
end