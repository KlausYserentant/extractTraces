function [ccAverage, ccStd] = histogramCorrectionCoefficient(cc, axes_handle)
% create fret efficiency and stoichiometry histograms (separate and combined)
    
    % TODO make this variable/or an optional parameter
    binSize = 0.02;
    binEdges = min(cc):binSize:max(cc);
    binCenters = min(cc)+binSize/2:binSize:max(cc)+binSize/2;
    
    % calculate simple 1d histogram
    [ccN, ccBin] = histc(cc(:), binEdges);
    
    % plot the correctionCoefficient histogram
    axes(axes_handle);
    hold off;
    bar(binCenters, ccN, 'k');
    ylabel('#');
    xlabel('Correction Coefficient')
    
    % calculate the average correctionCoefficient and the standard
    % deviation
    
    ccAverage = mean(cc);
    ccStd = std(cc);
    
end


