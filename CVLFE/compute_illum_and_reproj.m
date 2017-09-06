addpath( '../utilities/' );
% thirdparty tools needed
addpath( '../thirdparty/matlab-tree/' ); % for tree structure;
addpath( '../thirdparty/SART' ); % for SART solver
clear;

numberNeurons = 30;
nmfMethod = 'default';


%% LOADING DATA:
load_scan_sim_data; % external script




%% SETTINGS:

sartIter = 500; % 200 should be enough! (exponential decrease!)
illum_thresholds_from_max = [0.01 0.05 0.1 0.2 0.5 1];
thresholdMethod = 'thresh'; %'' default; 'maxOnly' only maximum.
DEBUG = false;
PENALTY = false; % penalize wrong illumination!
INIT_WITH_FULLILLUM_AND_B = true; % initialize the footprint with full illumintion (best results so far!)

%% init recorder for reproj simulation
recorder = RecordingSimulate( gtD, A );


%% OPTIMIZE FOR ILLUM PATTERNS
dst_folder = fullfile( scanning_dir, 'reproj', sprintf( 'reproj_scan_nmf%s_SART%d', nmfMethod, sartIter ) );

if INIT_WITH_FULLILLUM_AND_B
    dst_folder = [dst_folder '_initB'];
end
if PENALTY
    dst_folder = [dst_folder '_penalty'];
end



D = nmf.Dnmf; %
try 
    B = lighttransport.estT; % load matrix
catch 
    try 
        B = lighttransport.B; % load light transport!
    catch
        if isfield(lighttransport,'Bsart')
            B = lighttransport.Bsart;
        elseif isfield(lighttransport,'B')
            B = lighttransport.B;
        else
            error( 'cannot load light transport matrix (B or Bsart)!' );
        end
    end
end

nIllum = lighttransport.nIllum;
assert( numberNeurons == size(nmf.Dnmf,2) );
%numberNeurons = lighttransport.numberNeurons;

illumBs = cell( numberNeurons, 1 );
% plot_lfs( D, size(nmf.lf), [], [], nmf.nonzeroRays );

% full B
B_ = sparse( numel(lighttransport.nonZeroRays), size(B,2) );
B_(lighttransport.nonZeroRays,:) = B(:,:);

% full D
D_ = zeros( numel(lighttransport.nonZeroRays), size(D,2));
D_(nmf.nonZeroRays,:) = D(:,:);

% only use thresholded!!
% -> lighttransport.threshNonZeros
D_ = D_(lighttransport.nonZeroRays,:);
B_ = B_(lighttransport.nonZeroRays,:);
nonzerosI = lighttransport.nonZeroRays;
if INIT_WITH_FULLILLUM_AND_B
    fullIllum = B_ * ones(nnz(lighttransport.nonZeroIllumRays),1);
end

%%


%r = lighttransport.RES;

progBar = AdvancedTextProgressBar();
progBar.SetMaxCount(numberNeurons);
progBar.UpdateText( 'solve illuminations with SART ' );
progBar.UpdateProgress(0);

for i_neuron = 1:numberNeurons;
    progBar.UpdateText( sprintf( 'solve illumination %d with SART ', i_neuron) );
    D_i =  D_(:,i_neuron);
    sorted_D_i = sort( D_i, 'descend' );
    max_D_i = median( sorted_D_i(1:100) ); % use top 100 to deal with outliers!
    
    [ thresh_D_i, thresh_D_i_nz ] = auto_threshold( D_i, D_i>(max_D_i*0.1), 0 );
    if PENALTY
        D_i(D_i<=0) = -fullIllum(D_i<=0);
    end
    if INIT_WITH_FULLILLUM_AND_B
        D_i(thresh_D_i_nz) = fullIllum(thresh_D_i_nz);
        D_i(~thresh_D_i_nz) = 0;
        D_i(D_i>255) = 255; % clamp
    end
    
    
    illumBs{i_neuron} = SART2(B_, D_i, zeros(nIllum,1), ones(nIllum,1), zeros(nIllum,1), sartIter, false );
    
    illum4D = reshape2LF(  illumBs{i_neuron}, lighttransport.illum4D_redsize, lighttransport.nonZeroIllumRays );
    
    
    % continuos (not binarized) SIMULATION
    dst_folder_local = [dst_folder '_threshNO'];
    if ~exist(dst_folder_local,'dir'), mkdir( dst_folder_local ); end;


    seedsfilename = fullfile( dst_folder_local, sprintf( 'N%d.mat', i_neuron ) );
    contIllum = double( illum4D );
    recorder = recorder.pushIllum( contIllum, seedsfilename );
    recorder = recorder.wait();
    [recorder, reprojImg, exposure] = recorder.popImaging( seedsfilename );
    
    save( seedsfilename, 'contIllum', 'reprojImg', 'exposure',  '-v7.3' );
    writeReprojImgs( reshape2LF( reprojImg, full_lf_size ), contIllum, dst_folder_local, sprintf( 'N%d', i_neuron ) )
        
    
    %% BINARY ILLUMINATION
    % loop over thresholds!
    for illum_threshold_from_max = illum_thresholds_from_max
        %
        assert( strcmpi( thresholdMethod, 'thresh' ) );
        
        thresh = illum_threshold_from_max * max(illum4D(:));
        dst_folder_local = [dst_folder '_thresh' num2str(illum_threshold_from_max)];
        if ~exist(dst_folder_local,'dir'), mkdir( dst_folder_local ); end;
        
        
        seedsfilename = fullfile( dst_folder_local, sprintf( 'N%d.mat', i_neuron ) );
        binaryIllum = double( illum4D >= thresh );
        recorder = recorder.pushIllum( binaryIllum, seedsfilename );
        recorder = recorder.wait();
        [recorder, reprojImg, exposure] = recorder.popImaging( seedsfilename );
        
        
%         
%         [ s,t,u,v ] = compute_seeds_from_lowres_illumlf( illum4D >= thresh, r );
%         % store SEED MATRICES
        save( seedsfilename, 'binaryIllum', 'reprojImg', 'exposure', 'illum_threshold_from_max', '-v7.3' );
        writeReprojImgs( reshape2LF( reprojImg, full_lf_size ), binaryIllum, dst_folder_local, sprintf( 'N%d', i_neuron ) )

        
        if DEBUG && illum_threshold_from_max == 1
            h_fig1 = figure( 'Name', [ 'ILLUM - neuron: ' num2str(i_neuron) ', thresh: ', num2str(illum_threshold_from_max) ] );
            plot_lfs( cat(2, illum4D(:), illum4D(:) >= thresh ), size(illum4D), {['illum ' num2str(i_neuron)], ['illum-thresh ' num2str(i_neuron)]}, h_fig1 );
            illum4D_ = illum4D(:);
            estImg = B_ * illum4D_(lighttransport.nonZeroIllumRays);
            %estImg(estImg>1) = 1; % clamp
            estImgThresh = B_ * (illum4D_(lighttransport.nonZeroIllumRays) >= thresh);
            %estImgThresh(estImgThresh>1) = 1; % clamp
            h_fig2 = figure( 'Name', [ 'IMAGING - neuron: ' num2str(i_neuron) ', thresh: ', num2str(illum_threshold_from_max) ] );
            plot_lfs( cat(2, gtD(nonzerosI,i_neuron), D_i, estImg, estImgThresh), nmf.lf_size, {'fullillum', [ 'footprint ' num2str(i_neuron)], 'est. illum', 'est. illum-thresh' }, ...
                h_fig2, nonzerosI );
            drawnow();
        end
    end
   
    
    progBar.UpdateProgress(i_neuron);
end
progBar.Finish();

save( fullfile( fileparts( dst_folder ), 'workspace.mat' ), '-v7.3' );

