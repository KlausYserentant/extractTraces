classdef MappingAlex < handle
    % mapping between photon stream indices and names for ALEX data
    
    properties
        excitationOdd = 'donor';
        detectionLeft = 'donor';
        
        % constant list of all available photon streams in the order in
        % which they usually appear.
        names = {'AexAem', 'AexDem', 'DexAem', 'DexDem'};
%         names = {'RedExRedEm', 'RedExGreenEm' 'GreenExRedEm' 'GreenExGreenEm'};
        
        photonStreamNames = [];
        photonStreamIndices = [];
    end
    
    properties (Dependent)
        numPhotonStreams;
    end
    
    methods
        function obj = MappingAlex(excitationOdd, detectionLeft)
            obj.excitationOdd = excitationOdd;
            obj.detectionLeft = detectionLeft;
        end
        
        function set.excitationOdd(obj, value)           
            if ~strcmpi(value, {'donor', 'acceptor'})
                error('MappingAlex:InvalidExcitationOdd', ...
                      '\"%s\" is invalid. must be \"donor\" or \"acceptor\"', value)
            end
            obj.excitationOdd = lower(value);
            obj.updateMapping();
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
        
        function [iDs, iAs] = indicesDonorAcceptor(obj, numFrames)
            % image indices in the movie for donor / acceptor excitation
            %
            % numFrames is the number of logical frames in the movie
            
            if strcmpi(obj.excitationOdd, 'donor')
                iDs = 1:2:(2 * numFrames);
                iAs = 2:2:(2 * numFrames);
            else
                iDs = 2:2:(2 * numFrames);
                iAs = 1:2:(2 * numFrames);
            end
        end
    end
    
    methods (Access = protected)
        function updateMapping(obj)
            % update the mapping between photon stream names and indices
            %
            % create the photonStreamNames cell array that contains the names
            % of each stream in the following order (corresponding index)
            %   (1) odd frames left
            %   (2) odd frames right
            %   (3) even frames left
            %   (4) even frames right
            
            
            if strcmpi(obj.excitationOdd, 'donor')
                if strcmpi(obj.detectionLeft, 'donor')
                    order = {'DexDem', 'DexAem', 'AexDem', 'AexAem'};
                else
                    order = {'DexAem', 'DexDem', 'AexAem', 'AexDem'};
                end
            else
                if strcmpi(obj.detectionLeft, 'donor')
                    order = {'AexDem', 'AexAem', 'DexDem', 'DexAem'};
                else
                    order = {'AexAem', 'AexDem', 'DexAem', 'DexDem'};
                end
            end
            
            % update index -> name mapping
            obj.photonStreamNames = order;
            % update name -> index mapping
            obj.photonStreamIndices = containers.Map(order, 1:numel(order));
        end
    end
end
