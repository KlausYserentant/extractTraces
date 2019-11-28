function plotTraceIntensitiesOneColor(trace_, axesRaw, axesCorrected)
% plot the intensities from the trace in the two given axes
    
    iF = trace_.mapping.indices(trace_.intensityCount);
    
    % intensities uncorrected = raw and background
    axes(axesRaw);
    cla;
    hold on;
    plot(iF, trace_.rawByName('Fem'), '-*', 'Color', [0,0,1]);
    plot(iF, trace_.backgroundByName('Fem'), '--*', 'Color', [0,0,0.5]);
    title('Fluorescence Intensities and Background');
    hold off;
    
    % donor intensities
    axes(axesCorrected);
    cla;
    hold on;
    plot(iF, trace_.correctedByName('Fem'), '-*', 'Color', [0,0,1]);
    title('Background Corrected Fluorescence Intensities');
    hold off;
end