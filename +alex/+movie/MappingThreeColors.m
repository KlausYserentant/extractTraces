classdef MappingThreeColors < handle
    % mapping between photon stream indices and names for ALEX data
    
    properties
        frameOrder = 'blue-green-red';
        
        % constant list of all available photon streams in the order in
        % which they usually appear.
        names = {'BlueEM', 'GreenEM', 'RedEM'};
        
        photonStreamNames = [];
        photonStreamIndices = [];
    end
    
    properties (Dependent)
        numPhotonStreams;
    end
    
    methods
        function obj = MappingThreeColors(frameOrder)
            obj.frameOrder = frameOrder;
        end
        
        function set.frameOrder(obj, value)
            if ~strcmpi(value, {'blue-green-red','blue-red-green', 'green-red-blue','green-blue-red','red-blue-green','red-green-blue'})
                error('MappingAlex:InvalidDetectionLeft', ...
                      '\"%s\" is invalid.', value)
            end
            obj.frameOrder = lower(value);
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
            % of each stream in the follcontainersowing order (corresponding index)
            %   (1) frames left
            %   (2) frames middle
            %   (3) frames right
            
            if strcmpi(obj.frameOrder, 'blue-green-red')
                order = {'BlueEM', 'GreenEM', 'RedEM'};
            elseif strcmpi(obj.frameOrder, 'blue-red-green')
                order = {'BlueEM', 'RedEM', 'GreenEM'};
            elseif strcmpi(obj.frameOrder, 'green-red-blue')
                order = {'GreenEM', 'RedEM', 'BlueEM'};
            elseif strcmpi(obj.frameOrder, 'green-blue-red')
                order = {'GreenEM', 'BlueEM', 'RedEM'};
            elseif strcmpi(obj.frameOrder, 'red-blue-green')
                order = {'RedEM', 'BlueEM', 'GreenEM'};
            elseif strcmpi(obj.frameOrder, 'red-green-blue')
                order = {'RedEM', 'GreenEM', 'BlueEM'};
            else
                order = {'BlueEM','GreenEM','RedEM'};
            end
            
            % update index -> name mapping
            obj.photonStreamNames = order;
            % update name -> index mapping
            obj.photonStreamIndices = containers.Map(order, 1:numel(order));
        end
    end
end