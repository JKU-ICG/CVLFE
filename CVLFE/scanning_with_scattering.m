addpath( '../utilities/' );
% thirdparty tools needed
addpath( '../thirdparty/matgraph' ); % for scheduling with color graph
addpath( '../thirdparty/matlab-tree/' ); % for tree structure;
addpath( '../thirdparty/nmfv1_4' ); % nmf

clear;

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETTINGS for the PROBE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global batch_use_batch; 
if batch_use_batch
    global batch_params;
    sigma = batch_params.sigma;
else
    sigma = 0.0010; % scattering coefficient (lower means less scattering)
end
reduceResolution = 1; % reduce lf resolution for speedup!
noise_level = 0.0; % noise in data!

LOAD_PROBE = true; % random probe for each run if false
numberNeurons = 30;
neuronSize = 10; %µm (radius)

useRoundAperture = true;
probeHeight = 103.9596837565010; % FocusRange

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folder = '../data/';
if useRoundAperture, apertureStr='roundAp_'; else apertureStr=''; end;
filename = sprintf( 'probe_scattering_n%d_%ssigma%f_res%.2f.mat', numberNeurons, apertureStr, sigma, reduceResolution );
probeStr = sprintf( 's%.3f', sigma );
if LOAD_PROBE && exist( fullfile( folder, filename ), 'file' )
    load( fullfile( folder, filename ) );
    fprintf( 'loaded probe from %s.\n', fullfile( folder, filename ) );
else
    error( 'the probe does not exist in the data folder!' );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETTINGS for SCANNING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

illum4D_redsize = [11    15     7     7] %size( ilfs{1} );

max_similarity_thresh = 1.0; % maximum allows similarity threshold!
% background level for recorded images
bg_level_255 = 8; % used for thresholding! (default with microsope data: 5)
threshold_factor = 0.8; % auto threshold factor (default with microscope data: 0.5)
similariy_threshold = 0.1; % for detrmining similar recordings
measured_similarity_thresh = 0;
num_rays_for_conflict = 50; % so many rays must overlap to count as conflict!!!
num_rays_for_empty = num_rays_for_conflict; % if less rays are in image after auto_threshold, discard!
a_threshold = 0.0001; % thresholding on A to make illum more sparse! (determined experimentally)

DEBUG = true;

DELETE_EMPTY_RAYS = true;
DELETE_EMPTY_ILLUM_RAYS = true;
SAVE = true;
USE_SCHEDULE = true;
max_level = 10; 
USE_EARLY_STOPPING = true;
USE_2D_NEIGHBOURHOOD = true;
IGNORE_CONFLICTS = false; % ONLY USE FOR DEBUGGING!!!
SPLIT_TYPE = 'neighbourhood'; %'neighbourhood'; 'random'
USE_AUTO_EXPOSURE = true; % if implemented in python program
DELETE_NONZEROS_IN_BLANK = true; % nonzero pixels in blank fram are deleted!
ALWAYS_THRESH_CHILD = true; % aply threshold on children

DEBUG_TESTRUN = false;

% create an object for recording
% simulates a microscope with SLM, CAM etc. ...
recorder = RecordingSimulate( Dexpect, A );


numChildrenPerSplit = 4;
assert( strcmp( SPLIT_TYPE, 'neighbourhood' ) && USE_2D_NEIGHBOURHOOD );

settingsStr = sprintf( 'n%d_%s_bL%d_tF%.3f', numberNeurons, probeStr, bg_level_255, threshold_factor );
if ~USE_SCHEDULE, settingsStr = [settingsStr '_NOschedule']; end;
if a_threshold > 0, settingsStr = sprintf( '%s_Athresh%.4f', settingsStr, a_threshold); end;
backup_dir = [ '../results/scanning_with_scattering/sim_' settingsStr '_' datestr(now,'yyyymmdd_HHMM') ];
if ~exist( backup_dir, 'dir' ); mkdir( backup_dir ); end;
if batch_use_batch
    global batch_scanning_dir;
    batch_scanning_dir = backup_dir; 
end

%% TIMING
t_all = tic();

%% FIRST RECORD FULL AND NO ILLUMINATION



fullIllum_illum = ones(illum4D_redsize);
recorder = recorder.pushIllum( fullIllum_illum, 'full' );
recorder = recorder.wait();
[recorder, fullIllum, exposure] = recorder.popImaging( 'full' );
%fullIllum = simulate_illumination( Dexpect, A, fullIllum_illum );

allOnesImaging = fullIllum;
noIllum = zeros( size( fullIllum ) );

% some tests to make sure everything works as expected!
assert( isequal( fullIllum, auto_threshold( fullIllum, true(size(fullIllum)), 0, 0 ) ) );

[tFullIllum, maskFullIllum] = auto_threshold( fullIllum, true(size(fullIllum)), bg_level_255, threshold_factor );



if DELETE_EMPTY_RAYS
    nonZeroRays = fullIllum > bg_level_255;
else
    nonZeroRays = true(size(fullIllum));
end

if DELETE_EMPTY_ILLUM_RAYS
    nonZeroIllumRays = fullIllum_illum > bg_level_255;
    %fullIllum_illum
else
    nonZeroIllumRays = true(size(fullIllum_illum));
end

origA = A;
if a_threshold > 0
    A(A<a_threshold) = 0;
end




nImaging = nnz(nonZeroRays);
nIllum = nnz(nonZeroIllumRays);

% measured background noise

measured_bg = mean( noIllum(:) ); %sum( fullIllum( ~maskFullIllum ) ) ./ numel( fullIllum );
fprintf( 'measured BG: %f\n', measured_bg );


measured_snr_full = mean(fullIllum(nonZeroRays)) / measured_bg;
fprintf( 'measured SNR: %f\n', measured_snr_full );


all_sum_images = {};
all_sum_images{1} = fullIllum; % first illumination is full illumination!
stored_NMF = {};
i_stored_NMF = 0;


%%
lf_size = [42    56    35    35]; %
full_lf_size = lf_size;
illuminations = cell(1);
illuminations{1,1} = {1:illum4D_redsize(1),1:illum4D_redsize(2),1:illum4D_redsize(3),1:illum4D_redsize(4)}; % full illumination is zero level



% STORE IN A TREE-LIKE STRUCTURE
t = tree( struct( 'illumIds', illuminations, 'img', fullIllum, 'exposure', exposure ) ); %#ok<NASGU,NOPTS>
next_parentNodes = 1; parentNodes = []; % 1 is always root node!

tSumRays = tree( sum(fullIllum(:)) );

% some counters for debug output
count_illuminations = 1; % already set to one for root
count_illums_schedule = 1;  % already set to one for root
count_early_stoppings = 0;
count_nmf_stoppings = 0;

conflict = false( 1 );
similarToParent = false( 1 );
nmfSimilarToParent = false( 1 );
isEmpty = false( 1 );


status = StatusLine();

continue_splits = true; i_level = 1;
while true == continue_splits && i_level <= max_level
    fprintf( 'level %d contains %d root nodes.\n', i_level, numel(next_parentNodes) );
    
    prevnnodes = t.nnodes;
    
    prevParents = parentNodes;
    % assign new parent Nodes for iteration
    parentNodes = next_parentNodes;
    
    % SOME STATISTICS for current level
    cL_numChildren = 0;
    cL_numEmpty = 0;
    cL_numSimilar = 0;
    
    
    % compute snr
    if ~isempty( prevParents ) % not root!
        for n_p = prevParents
            [ parentImg, parentNZ ] = auto_threshold( getImgExpCorrect( t, n_p ), nonZeroRays, bg_level_255, threshold_factor );
            snr_parent = mean(parentImg(nonZeroRays)) / measured_bg;
            childImgs = zeros(numel(nonZeroRays),length(t.getchildren(n_p)));
            nchildren = t.getchildren(n_p);
            for i_nc = 1:numel(nchildren)
                childImg = getImgExpCorrect( t, nchildren(i_nc) );
                childImgs(:,i_nc)  = auto_threshold( childImg(:), nonZeroRays, bg_level_255, threshold_factor );                
            end
            
            sum_childs = sum( childImgs(:,:), 2 );
            %sum_childs( sum_childs > 255 ) = 255; % clamp!
            snr_childs = mean(sum_childs(nonZeroRays)) / measured_bg;
            [ ndifference, difference ] = similartiy_recordings( parentImg(parentNZ), sum_childs(parentNZ) );
            
            if length(nchildren) == numChildrenPerSplit
                if ndifference < max_similarity_thresh
                    measured_similarity_thresh = max( measured_similarity_thresh, ndifference ); % always take worst measurement!
                else
                    fprintf( 'measured_similarity_thresh above 1!' );
                    % IDEALLY THIS SHOULD NOT HAPPEN, but can happen due to thresolding!
                end

            end
        end
    end
    
    %% COMPUTE CONFLICTS!
    progBar = AdvancedTextProgressBar();
    progBar.SetMaxCount(numel(parentNodes(:)));
    progBar.UpdateText( 'compute conflicts ... ' );
    progBar.UpdateProgress(0);   i_pn = 0;
    
    % schedule to record in parallel and avoid conflicts!!!
    % compute conflicts with other recordings for parallelization!
    parent_conflicting_rays = false( sum(nonZeroRays(:)), 1 );

    for n1 = parentNodes
        n1Img = getImgExpCorrect( t, n1 ); %t.get(n1).img;
        for n2 = parentNodes
            if n1 < n2 % optimization!
                nn_conflicting_rays = detect_conflicts( getImgExpCorrect( t, n2 ), n1Img, nonZeroRays, bg_level_255, noIllum, fullIllum );
                
                conflicting_rays = nn_conflicting_rays(nonZeroRays);
                if n1~=n2 && nnz( conflicting_rays ) > num_rays_for_conflict
                    conflict(n1,n2) = true;
                    conflict(n2,n1) = true;

                    parent_conflicting_rays = parent_conflicting_rays | conflicting_rays;
                else
                    conflict(n1,n2) = false;
                    conflict(n2,n1) = false;
                    
                end
                
            end
        end
        i_pn = i_pn + 1;
        progBar.UpdateProgress(i_pn);
    end
    progBar.Finish();
    
    
    fprintf( 'conflicting rays: %d out of %d\n', sum( parent_conflicting_rays ), sum(nonZeroRays(:)) );
    
    %% COMPUTE SCHUEDULE
    if numel( parentNodes ) == 1
        runparallel = 1;
        schedule = partition( parentNodes );
    elseif USE_SCHEDULE
        %free_all(); % from graph system
        g = graph();
        set_matrix(g, conflict( parentNodes, parentNodes ) );
        schedule = color(g, 'repeat', 5 ); % last parameter is time budget
        runparallel = np( schedule );
    end
    
    
    next_parentNodes = [];
    
    if USE_SCHEDULE
        scheduledNodes = parts(schedule);
        % ids of schedule have to be transfered to tree indices
        for i_r = 1:runparallel
            scheduledNodes{i_r} = parentNodes(scheduledNodes{i_r});
        end
        fprintf( 'running in parallel: %d of %d\n', runparallel, length( parentNodes ) );
        save( fullfile( backup_dir, sprintf( 'schedule_level%d', i_level ) ), 'scheduledNodes', '-v7.3' );
    else
        scheduledNodes = num2cell(parentNodes);
    end
    
    for i_schedule = 1:length( scheduledNodes );
        numParallelNodes = numel(scheduledNodes{i_schedule});
        childrens = {}; child_illums = {};
        sum_illum = {}; sum_img = {}; sum_img_illum = {}; sum_img_exposure = {};
        for i_parentNode = 1:numel(scheduledNodes{i_schedule})
            parentNode = scheduledNodes{i_schedule}(i_parentNode);
            count_illums_per_parent = 0;
            
            if DEBUG
                h_fig = figure(1);
                set( h_fig, 'Name', 'illumination and imaging' ); clf;
                               
                i_plot = 1;
            end
            
            
            switch SPLIT_TYPE
                case 'neighbourhood'
                    if ~USE_2D_NEIGHBOURHOOD
                        % USE 4D neighbourhood and splits!
                        [ childrens{i_parentNode}, child_illums{i_parentNode} ] = split_illumination( t.get(parentNode).illumIds, illum4D_redsize, 'valid_lf', fullIllum_illum>0 );
                    else
                        % split st first, and use uv when st splits are not possible
                        % anymore!
                        [ childrens{i_parentNode}, child_illums{i_parentNode} ] = split_illumination( t.get(parentNode).illumIds, illum4D_redsize, 'use_st_only', true, 'valid_lf', fullIllum_illum>0  );
                        split_used = 'st';
                        if isempty( childrens{i_parentNode} )
                            [ childrens{i_parentNode}, child_illums{i_parentNode} ] = split_illumination( t.get(parentNode).illumIds, illum4D_redsize, 'use_uv_only', true, 'valid_lf', fullIllum_illum>0  );
                            split_used = 'uv';
                        end
                        
                    end
                    childrens{i_parentNode} = reshape( childrens{i_parentNode}, [numel( childrens{i_parentNode} ),1] ); % make 1D
                    child_illums{i_parentNode} = reshape( child_illums{i_parentNode}, [numel( child_illums{i_parentNode} ),1] ); % make 1D
                otherwise
                    error( 'SPLIT_TYPE not implemented!' );
            end
            
            
            
            
            % iterate over children and store in tree
            for i_s = 1:numel( childrens{i_parentNode} )
                
                % only continue if child is not empty and valid indices
                if validate_cell( child_illums{i_parentNode}, i_s )
                    
                    % sum up illuminations forparallel recording
                    if ~validate_cell( sum_illum, i_s )
                        % lazy init
                        sum_illum{i_s} = child_illums{i_parentNode}{i_s}(:);
                    else
                        sum_illum{i_s} = sum_illum{i_s} + child_illums{i_parentNode}{i_s}(:);
                    end
                    
                end
            end % i_s, ... iterate over childrens
        end % i_parent
        
        
            % SIM RECORDINGS
            for i_s = 1:numel( sum_illum )
                % only continue if child is not empty
                if ~isempty( sum_illum { i_s } ) % try to avoid error!
                    recorder = recorder.pushIllum( sum_illum { i_s }, num2str( i_s ) );
                    recorder = recorder.wait();
                    [recorder, sum_img{i_s}, sum_img_exposure{i_s}] = recorder.popImaging( num2str( i_s ) );
                    %sum_img{i_s} = simulate_illumination( Dexpect, A, sum_illum { i_s } );
                    %[ sum_img{i_s}, sum_img_exposure{i_s} ] = import_imaging_lf( working_dir, seedsfilenames{i_s} );
                    % sum_img_illum{i_s} = import_illum_lf( working_dir, seedsfilenames{i_s},  RES, illum4D_redsize );
                    
                    
                    count_illums_schedule = count_illums_schedule + 1;
                    all_sum_images{count_illums_schedule} = sum_img{i_s};
                end
            end

        
        
        
        for i_parentNode = 1:numel(scheduledNodes{i_schedule})
            parentNode = scheduledNodes{i_schedule}(i_parentNode);
            % iterate over children and store in tree
            for i_s = 1:numel( childrens{i_parentNode} )
                
                % only continue if child is not empty
                if validate_cell( child_illums{i_parentNode}, i_s )
                    
                    
                    % extract child illuminations
                    childImg = sum_img{i_s};
                    childExposure = sum_img_exposure{i_s};
                    if numParallelNodes>1 || ALWAYS_THRESH_CHILD
                        [~,tParent] = auto_threshold( getImgExpCorrect( t, parentNode ), nonZeroRays, bg_level_255, threshold_factor );
                        childImg( ~tParent ) = 0.0; % set to 0 outside of parent image!
                    end
                    count_illuminations = count_illuminations + 1; % without parallel/schedule!
                    
                    
                    % if imaging is empty do not continue
                    if max(childImg(:))<bg_level_255
                        %if DEBUG, fprintf( 'empty image!\n' ); end;
                        cL_numEmpty = cL_numEmpty + 1;
                        continue;
                    end
                    
                    % if imaging is empty do not continue
                    if mean(childImg(nonZeroRays)) < measured_bg
                        %if DEBUG, fprintf( 'new empty image!\n' ); end;
                        cL_numEmpty = cL_numEmpty + 1;
                        continue;
                    end
                    
                    [ childImgThresh,tChild] = auto_threshold( double(childImg)./childExposure, nonZeroRays, bg_level_255, threshold_factor );
                    % if imaging is empty do not continue
                    if nnz(tChild) < num_rays_for_empty
                        %fprintf( 'empty image after auto threshold!\n' );
                        continue;
                    end
                    
                    % ADD TO TREE:
                    assert( ~isempty(  childrens{i_parentNode}{i_s} ) );
                    [t, childNode] = t.addnode(parentNode, struct( 'illumIds', { childrens{i_parentNode}{i_s} }, ...
                        'img', reshape2LF( childImg, full_lf_size ), 'exposure', childExposure ));
                    [tSumRays, childNodeSumRays ] = tSumRays.addnode(parentNode, sum( childImg(:) ) );
                    assert( childNode == childNodeSumRays );
                    
                    
                    cL_numChildren = cL_numChildren + 1;
                    %assert( numel(t.getsiblings(childNode)) == cL_numChildren );
                    
                    

                    
                    
                    % EARLY STOPPING
                    % compute similarity to parent! for early stopping!
                                        
                    [ parentImg, parentNZ ] = auto_threshold( getImgExpCorrect( t, parentNode ), nonZeroRays, bg_level_255, threshold_factor );
                    [ ndifference, difference ] = similartiy_recordings( parentImg(parentNZ), childImgThresh(parentNZ) );
                    
                    if ndifference <= similariy_threshold 
                        similarToParent( childNode ) = true;
                        cL_numSimilar = cL_numSimilar + 1;
                    else
                        similarToParent( childNode ) = false;
                    end
                    
                    if ndifference <= measured_similarity_thresh 

                        if ~similarToParent( childNode )
                            cL_numSimilar = cL_numSimilar + 1;
                        end
                        similarToParent( childNode ) = true;
                    end
                  
                    
                    
                    if DEBUG
                        % plot illuminations and corresponding recordings!
                        sb_x = numel(childrens{i_parentNode}); sb_y = 2;
                        figure( h_fig );
                        subplot( sb_x, sb_y, (i_plot-1)*2+1 );
                        %subplot( sb_x, sb_y, (i_plot-1)*2+1 );
                        imshow( mlaFromLF( child_illums{i_parentNode}{i_s}, false ), [] ); %title( 'illumination' );
                        subplot( sb_x, sb_y, (i_plot)*2 );
                        imshow( mlaFromLF( reshape2LF(childImg,full_lf_size), false ), [] ); %title( 'imaging' );
                        drawnow();
                        i_plot = i_plot + 1;
                    end
                
                else
                    cL_numEmpty = cL_numEmpty + 1;
                end % not empty children
                
                status.Update( sprintf( 'level: %2d, #nodes: %3d, #children: %d (#similar: %d), #empty: %d, ', ...
                        i_level, numel(parentNodes), cL_numChildren, cL_numSimilar, cL_numEmpty) );
                
            end % i_s, ... iterate over childrens
            
            potentialNextParentNodes = t.getchildren(parentNode);
            
            
            % check if all children are similar to parent
            if ~USE_EARLY_STOPPING || ~all(similarToParent(t.getchildren(parentNode)))
                % the current children are the parents of the next iteration
                next_parentNodes = cat(2, next_parentNodes, potentialNextParentNodes );
            else
                % recording the same as parent so STOP early
                %fprintf( 'early stopping!\n' );
                count_early_stoppings = count_early_stoppings + 1;
            end
            
            i_plot = 1;
            
        end % parentNodes
    end % i_schedule
    
    if isempty( next_parentNodes )
        continue_splits = false;
    end
       
%     if SAVE 
%         save( fullfile( backup_dir, sprintf( 'workspace_intermediate_l%d.mat', i_level ) ), '-v7.3' );
%     end
    
    status.Finish();
    
    %continue_splits = false;
    i_level = i_level + 1;
end % while continue_splits

%% TIMING
timingAll = toc(t_all);


fprintf( 'illuminations without scheduling: %d; with scheduling %d  \n', count_illuminations, count_illums_schedule );

%%

if SAVE 
    save( fullfile( backup_dir, 'workspace.mat' ), '-v7.3' );
end
