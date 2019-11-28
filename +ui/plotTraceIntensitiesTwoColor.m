function plotTraceIntensitiesTwoColor(trace_, axesAcceptor, axesDonor)
% plot the intensities from the trace in the two given axes
    
    iF = trace_.mapping.indices(trace_.intensityCount);
    
    % acceptor intensities
    axes(axesAcceptor);
    cla;
    hold on;
    plot(iF, trace_.rawByName('Aem'), '-*', 'Color', [1,0,0]);
    plot(iF, trace_.backgroundByName('Aem'), '--*', 'Color', [0.5,0,0]);
    title('Acceptor Detection Intensities');
    hold off;
    
    % donor intensities
    axes(axesDonor);
    cla;
    hold on;
    plot(iF, trace_.rawByName('Dem'), '-*', 'Color', [0,1,0]);
    plot(iF, trace_.backgroundByName('Dem'), '--*', 'Color', [0,0.5,0]);
    title('Donor Detection Intensities');
    hold off;
end