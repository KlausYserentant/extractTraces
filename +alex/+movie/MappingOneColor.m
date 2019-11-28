classdef MappingOneColor < handle
    % mapping between photon stream indices and names for one color 
    % detection data without ALEX
    
    properties
        
        % constant list of all available photon streams in the order in
        % which they usually appear. Here, only one photon stream.
        names = {'Fem'};

        photonStreamNames = [];
        photonStreamIndices = [];
    end
    
    properties (Dependent)
        numPhotonStreams;
    end
    
    methods
        function obj = MappingOneColor()
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
            % numFrames is the number of logical frames in the movie
            
            iFs = 1:1:numFrames;
        end
    end
    
    methods (Access = protected)
        function updateMapping(obj)
            % update the mapping between photon stream names and indices
            %
            % create the photonStreamNames cell array that contains the names
            % of the stream
            
            order = {'Fem'};
            
            % update index -> name mapping
            obj.photonStreamNames = order;
            % update name -> index mapping
            obj.photonStreamIndices = containers.Map(order, 1:numel(order));
        end
    end
end
