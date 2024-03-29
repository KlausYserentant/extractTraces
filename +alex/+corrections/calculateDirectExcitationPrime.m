function d = calculateDirectExcitationPrime(greenExGreenEm, greenExRedEm, leakage)
% calculate the direct excitation coefficient prime from a trace with 
% D and A and zero Fret Efficiency
    
    d = ( ...
            greenExRedEm - ...
            (leakage * greenExGreenEm) )./ ...
        greenExGreenEm;
end