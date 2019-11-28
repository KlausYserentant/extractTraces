function plotTraceCorrectionCoefficients(trace_, axes_, correctionCoefficient)
% plot the correction coefficient  from the trace in the given axes
    
    [iD, iA] = trace_.mapping.indicesDonorAcceptor(trace_.intensityCount);
    
    % both variables are identical for two correspondig images
    axes(axes_);
    cla;
    hold on;
    
    if strcmp(correctionCoefficient, 'l')
        plot(iA, trace_.leakageCoefficient, 'bx');
        plot(iD, trace_.leakageCoefficient, 'bx');
    else
        plot(iA, trace_.directExcitationCoefficient, 'bx');
        plot(iD, trace_.directExcitationCoefficient, 'bx');
    end
    
    title('Correction Coefficient');
end