classdef MappingTwoColors < handle
    % mapping between photon stream indices and names for ALEX data
    
    properties
        detectionLeft = 'donor';
        
        % constant list of all available photon streams in the order in
        % which they usually appear.
        names = {'Aem', 'Dem'};
        
        photonStreamNames = [];
        photonStreamIndices = [];
    end
    
    properties (Dependent)
        numPhotonStreams;
    end
    
    methods
        function obj = MappingTwoColors(detectionLeft)
            obj.detectionLeft = detectionLeft;
        end
        
        function set.detectionLeft(obj, value)
            if ~strcmpi(value, {'donor', 'acceptor'})
                error('MappingAlex:InvalidDetectionLeft', ...
                      '\"%s\" is invalid. must be \"donor\" or \"acceptor\"', value)
            end
            obj.detectionLeft = lower(value);
            obj.updateMapping();
        end
        
        function num = get.numPhotonStreams(obj)
            % number of photon streams defined in this mapping
            
            num = numel(obj.names);
        end
        
        function idx = getIndex(obj, name)
            % convert photon stream index to the corresponding name
            idx = obj.photonStreamIndices(name);
        end
        
        function name = getName(obj, idx)
            % convert photon stream name to the corresponding index
            
            name = obj.photonStreamNames{idx};
        end
        
        function iFs = indices(obj, numFrames)
            % image indices in the movie
            %
            % numFrames is the number of logical frames in the movie
            iFs = 1:1:numFrames;
        end
    end
    
    methods (Access = protected)
        function updateMapping(obj)
            % update the mapping between photon stream names and indices
            %
            % create the photonStreamNames cell array that contains the names
            % of each stream in the following order (corresponding index)
            %   (1) frames left
            %   (2) frames right
            
            if strcmpi(obj.detectionLeft, 'donor')
                order = {'Dem', 'Aem'};
            else
                order = {'Aem', 'Dem'};
            end
            
            % update index -> name mapping
            obj.photonStreamNames = order;
            % update name -> index mapping
            obj.photonStreamIndices = containers.Map(order, 1:numel(order));
        end
    end
end
