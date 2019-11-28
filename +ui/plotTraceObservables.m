function plotTraceObservables(trace_, axes_)
% plot the observables from the trace in the given axes
    
    [iD, iA] = trace_.mapping.indicesDonorAcceptor(trace_.intensityCount);
    
    % both variables are identical for two correspondig redex greenex frames
    axes(axes_);
    cla;
    hold on;
    plot(iA, trace_.fretEfficiency, 'bo');
    plot(iD, trace_.fretEfficiency, 'bo');
    plot(iA, trace_.stoichiometry, 'y*');
    plot(iD, trace_.stoichiometry, 'y*');
    ylim([-1.5, 1.5]);
    title('Fret Efficiency and Stochiometry');
end