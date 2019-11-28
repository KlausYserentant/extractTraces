function calculateCorrections(traces, correctionCoefficient, dIsPrime)
% calculate correctionCoefficients for all the given traces
% correctionCoefficient defines wether the leakage l or direct excitation
% coefficient d or dprime is calculated
    
    if nargin < 3
        dIsPrime = false;
    end
    
    if strcmp(correctionCoefficient, 'l')        
        for i = 1:length(traces)
            t = traces(i);

            t.leakageCoefficient = alex.corrections.calculateLeakage( ...
                t.correctedByName('GreenExGreenEm'), ...
                t.correctedByName('GreenExRedEm'));
        end
        
    else
        if dIsPrime
            % invoke question for leakage coefficient
            display('Sorry, not fully implemented yet!');
%             for i = 1:length(traces)
%             t = traces(i);
% 
%             t.directExcitationCoefficient = alex.corrections.calculateDirectExcitationPrime( ...
%                 t.calibratedByName('GreenExGreenEm'), ...
%                 t.calibratedByName('GreenExRedEm'), ...
%                 leakage);
%             end
        else
            for i = 1:length(traces)
            t = traces(i);

            t.directExcitationCoefficient = alex.corrections.calculateDirectExcitation( ...
                t.correctedByName('GreenExRedEm'), ...
                t.correctedByName('RedExRedEm'));
            end
        end
        
    end
end