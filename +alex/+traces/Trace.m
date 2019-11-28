classdef Trace < handle
    % storage class to hold all the information for a single trace
    %
    % this class is designed to be a container for all the trace
    % information and has little logic on its own to actually generate the
    % traces. it only containssome helper functions that use the data of
    % the trace, e.g. export emissions and calculate observables
    %
    % there are two different ways to access the intensities for different
    % photon streams:
    % - using a numerical index, e.g. trace.raw[:, 1]; this way you can
    %   loop over all available streams but you can not access a specific
    %   stream, because the mapping from indices to names is unknown.
    %   photon stream indices are, e.g. for ALEX data:
    %     1: odd frames, left detection channel
    %     2: odd frames, right detection channel
    %     3: even frames, left detection channel
    %     3: even frames, right detection channel
    %   or for two color detection:
    %     1: left detection channel
    %     2: right detection channel
    % - using a stream name and the ...ByName functions.
    %   this way uses the mapping object to map a given name to an index
    %   and return the corresponding intensities
    
    properties
        index = 0; % numerical identifier
        position = [0, 0];
        name = ''; % textual identifier
        
        % should be arrays with dimensionality [numFrames, numPhotonStreams]
        raw = [];
        background = [];
        corrected = [];
        
        % correction factors for the calculation of observables
        leakage = 0;
        directExcitation = 0;
        directExcitationPrime = 0;
        gamma = 1;
        
        % observables
        fretEfficiency = [];
        stoichiometry = [];
        
        % correction coefficients
        leakageCoefficient = [];
        directExcitationCoefficient = [];
        
        % this must be an alex.movie.Mapping object
        mapping = [];
    end
    
    properties (Dependent)
        intensityCount;
    end
    
    methods
        function obj = Trace(index, position, raw, background, mapping)
        % construct the Trace object and fill it with values
            
            obj.index = index;
            obj.position(:) = position(:);
            i = int2str(obj.index);
            x = int2str(obj.position(1));
            y = int2str(obj.position(2));
            obj.name = ['trace ' i ', position (' x ', ' y ')'];
            
            obj.raw = raw;
            obj.background = background;
            obj.corrected = raw - background;
            
            obj.mapping = mapping;
        end
        
        % function truth = isempty(obj)
        %     truth = (isempty(obj.raw) || isempty(obj.background) || ...
        %         isempty(obj.calibrated));
        % end
        
        function n = get.intensityCount(obj)
        % get the number of intensity measurements stored by this trace
            % first dimension is the numFrames
            n = min([size(obj.raw, 1), ...
                     size(obj.background, 1), ...
                     size(obj.corrected, 1)]);
        end

%         function indices = get.indicesRedEx(obj)
%         % get the frame indices corresponding to red excitation
%             
%             % the intensities are calculated from every second frame
%             % the total number of frames thus is twice the intensity count
%             indices = obj.calibration.calculateExcitationFrameIndices( ...
%                 'red', 2 * obj.intensityCount);
%         end
%         
%         function indices = get.indicesGreenEx(obj)
%         % get the frame indices corresponding to green excitation
%             
%             % the intensities are calculated from every second frame
%             % the total number of frames thus is twice the intensity count
%             indices = obj.calibration.calculateExcitationFrameIndices( ...
%                 'green', 2 * obj.intensityCount);
%         end
        
        function intensities = rawByName(obj, photonStreamName)
        % return the raw intensities for the given photon stream
            
            i = obj.mapping.photonStreamIndices(photonStreamName);
            intensities = obj.raw(:, i);
        end
        
        function intensities = backgroundByName(obj, photonStreamName)
        % return the background intensities for the given photon stream
            
            i = obj.mapping.photonStreamIndices(photonStreamName);
            intensities = obj.background(:, i);
        end
        
        function intensities = correctedByName(obj, photonStreamName)
        % return the background subtracted intensities for the given stream
            
            i = obj.mapping.photonStreamIndices(photonStreamName);
            intensities = obj.corrected(:, i);
        end
    end
end
