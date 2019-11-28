function extractTraces(obj)
% extract the traces for all peaks using the current settings
    
    peakPositions = obj.findPeaks();
    method = obj.traceAquisitionMethod;
    
    if strcmpi(method, 'max')
        createEmptyTracesArray = @alex.TraceMax.empty;
        constructTrace = @alex.TraceMax;
    elseif strcmpi(method, 'pixel')
        createEmptyTracesArray = @alex.TracePixel.empty;
        constructTrace = @alex.TracePixel;
    elseif strcmpi(method, 'sum')
        createEmptyTracesArray = @alex.TraceSum.empty;
        constructTrace = @alex.TraceSum;
    else
        error('ALEX:Trace:InvalidAquisitionMethod', ...
              'the trace aquisition method \"%s\" is invalid', ...
              method);
    end
    
    if not(isempty(peakPositions))
        % this creates an 1xN empty array of Trace* objects
        obj.traces = createEmptyTracesArray(size(peakPositions, 1), 0);
        for i = 1:size(obj.traces, 1)
            position = peakPositions(i, :);
            otherPositions = peakPositions;
            otherPositions(i, :) = [];
            obj.traces(i) = constructTrace(obj, position, otherPositions);
        end
        % correct the dimensions to Nx1
        obj.traces = transpose(obj.traces);
    end
end
