function plotTraceIntensities(trace_, axesAcceptor, axesDonor)
% plot the intensities from the trace in the two given axes
    
    [iD, iA] = trace_.mapping.indicesDonorAcceptor(trace_.intensityCount);
    
    % acceptor intensities
    axes(axesAcceptor);
    cla;
    hold on;
    plot(iA, trace_.rawByName('AexAem'), '-*', 'Color', [1,0,0]);
    plot(iD, trace_.rawByName('DexAem'), '-o', 'Color', [0,1,0]);
    plot(iA, trace_.backgroundByName('AexAem'), '--*', 'Color', [0.5,0,0]);
    plot(iD, trace_.backgroundByName('DexAem'), '--o', 'Color', [0,0.5,0]);
    title('Acceptor Detection Intensities');
    hold off;
    
    % donor intensities
    axes(axesDonor);
    cla;
    hold on;
    plot(iA, trace_.rawByName('AexDem'), '-o', 'Color', [1,0,0]);
    plot(iD, trace_.rawByName('DexDem'), '-*', 'Color', [0,1,0]);
    plot(iA, trace_.backgroundByName('AexDem'), '--o', 'Color', [0.5,0,0]);
    plot(iD, trace_.backgroundByName('DexDem'), '--*', 'Color', [0,0.5,0]);
    title('Donor Detection Intensities');
    hold off;
end