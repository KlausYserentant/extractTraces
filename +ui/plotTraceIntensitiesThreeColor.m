function plotTraceIntensitiesThreeColor(trace_, axesAcceptor, axesDonor)
% plot the intensities from the trace in the two given axes
    
    iF = trace_.mapping.indices(trace_.intensityCount);
    
    % acceptor intensities
    axes(axesAcceptor);
    cla;
    hold on;
    plot(iF, trace_.rawByName('BlueEM'), '-*', 'Color', [0,0,1]);
    plot(iF, trace_.backgroundByName('BlueEM'), '--*', 'Color', [0,0,0.5]);
    plot(iF, trace_.rawByName('GreenEM'), '-*', 'Color', [0,1,0]);
    plot(iF, trace_.backgroundByName('GreenEM'), '--*', 'Color', [0,0.5,0]);
    plot(iF, trace_.rawByName('RedEM'), '-*', 'Color', [1,0,0]);
    plot(iF, trace_.backgroundByName('RedEM'), '--*', 'Color', [1,0,0]);
    title('Fluorescence Intensities and Background');
    hold off;
    
    % donor intensities
    axes(axesDonor);
    cla;
    hold on;
    plot(iF, trace_.correctedByName('BlueEM'), '-*', 'Color', [0,0,1]);
    plot(iF, trace_.correctedByName('GreenEM'), '-*', 'Color', [0,1,0]);
    plot(iF, trace_.correctedByName('RedEM'), '-*', 'Color', [1,0,0]);
    title('Background Corrected Fluorescence Intensities');
    hold off;
end