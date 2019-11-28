function calculateObservables(traces, leakage, d, gamma, dIsPrime)
% calculate observables for all the given traces
    
    if nargin < 5
        dIsPrime = false;
    end
    
    if dIsPrime
        directExcitation = 0;
        directExcitationPrime = d;
        calcE = @alex.fret.calculateFretEfficiency;
        calcS = @alex.fret.calculateStoichiometry;
    else
        directExcitation = d;
        directExcitationPrime = 0;
        calcE = @alex.fret.calculateFretEfficiencyPrime;
        calcS = @alex.fret.calculateStoichiometryPrime;
    end
    
    for i = 1:length(traces)
        t = traces(i);
        
        t.fretEfficiency = calcE( ...
            t.correctedByName('DexDem'), ...
            t.correctedByName('DexAem'), ...
            t.correctedByName('AexAem'), ...
            leakage, d, gamma);
        t.stoichiometry = calcS( ...
            t.correctedByName('DexDem'), ...
            t.correctedByName('DexAem'), ...
            t.correctedByName('AexAem'), ...
            leakage, d, gamma);
        
        t.leakage = leakage;
        t.directExcitation = directExcitation;
        t.directExcitationPrime = directExcitationPrime;
        t.gamma = gamma;
    end
end