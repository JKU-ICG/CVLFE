addpath( '../utilities/' );
% thirdparty tools needed
addpath( '../thirdparty/matgraph' ); % for scheduling with color graph
addpath( '../thirdparty/matlab-tree/' ); % for tree structure;
addpath( '../thirdparty/nmfv1_4' ); % nmf
clear;

% FIRST LOAD WORKSPACE,
global batch_scanning_dir
if isempty( batch_scanning_dir )
    error( 'scanning_dir not specified!' );
end

scanning_dir = batch_scanning_dir;
load( fullfile( scanning_dir, 'workspace.mat') );

if nIllum == 0
    nIllum = prod( illum4D_redsize );
    nonZeroIllumRays = true( illum4D_redsize );
end
estT = sparse( nImaging, nIllum );
setIllum = false( nIllum, 1 );

%% iterate through stored tree

nextParents = 1;

if strcmpi( SPLIT_TYPE, 'neighbourhood' ) && USE_2D_NEIGHBOURHOOD
    maxNumChildren = 4;
else
    error( 'not implemented!' );
end

progBar = AdvancedTextProgressBar();
progBar.SetMaxCount(nIllum);
progBar.UpdateText( 'create estimate for T ' );
progBar.UpdateProgress(0);

while true
    currentParents = nextParents;
    nextParents = [];
    for p = currentParents
        if t.isleaf(p) % numel(children) ~= maxNumChildren
            illum = false( illum4D_redsize );
            illum( t.get(p).illumIds{1}, t.get(p).illumIds{2}, ...
                t.get(p).illumIds{3}, t.get(p).illumIds{4} ) = true;
            
            % normalize image by the number of used illumination rays!
            numNonZeroIllumRays = nnz(illum(nonZeroIllumRays));
            %normImgLf = double(t.get(p).img(nonZeroRays))./numNonZeroIllumRays;
            
                       
            % correct with exposure
            %threshImg = double(threshImg) ./ t.get(p).exposure;
            threshImg = getImgExpCorrect( t, p );
            
            estT( :, illum(nonZeroIllumRays) ) =  repmat( threshImg(nonZeroRays), [1 numNonZeroIllumRays] );
            setIllum(illum(nonZeroIllumRays)) = true;
            progBar.UpdateProgress(nnz(setIllum));
        end
        children = t.getchildren(p);
        nextParents = [nextParents children];
    end
    if isempty( nextParents )
        break;
    end
    progBar.UpdateProgress(nnz(setIllum));
end
progBar.Finish();

%assert( all( setIllum ) );

%% STORE ESTIMATED LIGHT TRANSPORT
save( fullfile( scanning_dir, 'lighttransport.mat' ), 'estT', 'nonZeroRays', 'nonZeroIllumRays', 'nImaging', 'nIllum',  'illum4D_redsize', '-v7.3' ); 
