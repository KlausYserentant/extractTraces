function histogramES(e, s, axesE, axesS, axesES)
% create fret efficiency and stoichiometry histograms (separate and combined)
    
    % TODO make this variable/or an optional parameter
    binSize = 0.02;
    limits = [-0.25, 1.25];
    
    binEdges = limits(1):binSize:limits(2);
    binCount = size(binEdges, 2) - 1;
    
    % calculate combined 2d histograms
    es = zeros(binCount);
    % calculates the bin index for each observable measurement
    eBinIndices = floor((e - limits(1)) / binSize) + 1;
    sBinIndices = floor((s - limits(1)) / binSize) + 1;
    % cut all observables that fall outside the limits
    cut = eBinIndices >= 1 & eBinIndices <= binCount & ...
        sBinIndices >= 1 & sBinIndices <= binCount;
    eBinIndices = eBinIndices(cut);
    sBinIndices = sBinIndices(cut);
    % TODO try..catch probably not needed bc of the cleanup/cut above
    try
        for i = 1:numel(eBinIndices);
            % y-index (stoichiometry) is reversed to accomodate for the
            % strange (different meaning of axes) behaviour of imagesc
            eBinIndex = eBinIndices(i);
            sBinIndex = binCount - sBinIndices(i) + 1;
            es(sBinIndex, eBinIndex) = es(sBinIndex, eBinIndex) + 1;
        end
    catch ME %#ok
        disp([eBinIndex sBinIndex])
        disp(binCount);
        disp('--');
    end
    
    % calculate simple 1d histograms
    [eN, eBin] = histc(e(:), binEdges);
    [sN, sBin] = histc(s(:), binEdges);
    
    % plot the fret efficiency histogram
    axes(axesE);
    hold off;
    bar(binEdges, eN, 'k');
    xlim(limits);
    ylabel('#');
    %xlabel('E')
    % plot the stoichiometry histogram
    axes(axesS);
    hold off;
    barh(binEdges, sN, 'k');
    ylim(limits);
    xlabel('#');
    %ylabel('S')
    
    % plot the combined es histogram
    axes(axesES);
    hold off;
    imagesc(es);
    colormap(flipud(colormap('gray')));
    axis([1 binCount 1 binCount]);
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    xlabel('Fret  Efficiency', 'FontSize', 10);
    ylabel('Stoichiometry', 'FontSize', 10);

% -----------------------------------------
% code from masterbranch
    % 
    % limits = [-0.25, 1.25];
    % binSize = str2num(get(handles.binSize, 'String'));
    % 
    % % select the source for efficiency and stochiometry
    % switch get(handles.esOrigin, 'Value')
    %     case 1
    %         eff = handles.newEff;
    %         stoich = handles.newStoch;
    %         
    %         sLabel = '#';
    %         eLabel = '#';
    %     case 2
    %         eff = handles.averageFretEfficiency;
    %         stoich = handles.averageStoichiometry;
    %    
    %         sLabel = '# average';
    %         eLabel = '# average';
    % end        
    % 
    % % select the data that lies inside the given limits
    % selectedIndices = eff>=limits(1) & eff<=limits(2) & ...
    %     stoich>=limits(1) & stoich<=limits(2);
    % eff = eff(selectedIndices);
    % stoich = stoich(selectedIndices);
    % 
    % % construct Histograms
    % binEdges = -0.25:binSize:1.25;
    % binCount = size(binEdges, 2) - 1;
    % 
    % % create 2d es histogram
    % es = zeros(binCount);
    % effBinIndex = floor((eff - limits(1)) / binSize) + 1;
    % stoichBinIndex = floor((stoich - limits(1)) / binSize) + 1;
    % try
    %     for i = 1:numel(effBinIndex);
    %         % y-index (stoichiometry) is reversed to accomodate for the
    %         % strange (different meaning of axes) behaviour of imagesc
    %         effIndex = effBinIndex(i);
    %         stoichIndex = binCount - stoichBinIndex(i) + 1;
    %         es(stoichIndex, effIndex) = es(stoichIndex, effIndex) + 1;
    %     end
    % catch ME %#ok
    %     disp([effBinIndex(i) stoichBinIndex(i)])
    %     disp(binCount);
    %     disp('--');
    % end
    % 
    % [effBin, binE] = histc(eff, binEdges, 2);
    % [stoichBin, binS] = histc(stoich, binEdges, 2);
    % 
    % % normalize histograms if requested
    % if (get(handles.checkbox,'Value') == get(handles.checkbox,'Max'))
    %     % Checkbox is checked-normalize
    %     normE = sum(effBin) * binSize;
    %     normS = sum(stoichBin) * binSize;
    %     
    %     sLabel = [sLabel ' normalized'];
    %     eLabel = [eLabel ' normalized'];
    % else
    %     % Checkbox is not checked-dont normalize
    %     normE = 1;
    %     normS = normE;
    % end
    % 
    % effBin = effBin./ normE;
    % stoichBin = stoichBin./ normS;
    % 
    % %plot Histograms
    % % E Histogram
    % axes(handles.eHist)
    % bar(binEdges,effBin,'k')
    % xlim([-0.25 1.25])
    % ylabel(eLabel)
    % %xlabel('E')
    % 
    % % E Histogram
    % axes(handles.sHist)
    % barh(binEdges,stoichBin,'k')
    % ylim([-0.25 1.25])
    % xlabel(sLabel)
    % %ylabel('S')

%     %Plot the S-E
%     esSize = size(bins, 2) - 1;
%     es = zeros(esSize, esSize);
%     for i = 1:length(binE)
%        es(esSize - binS(i), binE(i) + 1) = ...
%         es(esSize - binS(i), binE(i) + 1) + 1;
%     end

%     image((es * 256) / max(es(:)));

    % colormap
    %myCMap = zeros(max([binS, binE])+1,3);
    %myCMap(1,:) = 1;
    %myCMap(2:end,3) = transpose((1:1:max([binS, binE]))/max([binS, binE]));
%     esSize = size(binEdges, 2) - 1
    

    