addpath( '../utilities/' );
% thirdparty tools needed
addpath( '../thirdparty/matgraph' ); % for scheduling with color graph
addpath( '../thirdparty/matlab-tree/' ); % for tree structure;
addpath( '../thirdparty/nmfv1_4' ); % nmf
addpath( '../thirdparty/ompbox' ); % OMP-Box from Ron Rubinstein
clear;

% FIRST LOAD WORKSPACE,
numberNeurons = 30;
global batch_scanning_dir
if isempty( batch_scanning_dir )
    error( 'scanning_dir not specified!' );
end

scanning_dir = batch_scanning_dir;

load( fullfile( scanning_dir, 'workspace'), 't', 'numberNeurons', 'nonZeroRays', 'lf_size', 'illum4D_redsize', 'Dexpect', 'full_lf_size' );


rootImg = t.get(1).img;
maxRootImg = max(rootImg(:));

USE_FROM_TREE = true;
MAX_TREE_LEVEL = 10;
ONLY_LEAVES = true;
NUM_CHILDREN = 4;
DEBUG = false;
USE_RANDOM = false;
numRandomIllumsForFactorization = 1000;

factType = 'nmf';
if USE_RANDOM
    factType = [ factType '_rand' num2str( numRandomIllumsForFactorization ) ];
end
if ~ONLY_LEAVES
    factType = [ factType '_all' ];
end

%% find leaves

nodes_and_parents = zeros(1,t.nnodes, 'uint16');
nodes_levels = zeros(1,t.nnodes, 'uint8');
is_leaf = false( 1,t.nnodes );
X_ = zeros(0,0,'uint8');
k = 0;

for n = 1:t.nnodes
    
    if t.isleaf(n)
        is_leaf(n) = true;
    end
    
end

%% fill X for factorization

%X_ = zeros(nnz(nonZeroRays),nnz(is_leaf),'uint8');
k = 0;
nodeIds = 1:t.nnodes;
if ONLY_LEAVES
    nodeIds = nodeIds(is_leaf);
end
if USE_RANDOM
    randXIds = randperm( numel(nodeIds), numRandomIllumsForFactorization );
    nodeIds = nodeIds(randXIds);
end

XforFact = zeros(nnz(nonZeroRays), numel(nodeIds));

for n = nodeIds
    
    if ~ONLY_LEAVES || ( t.isleaf(n) )
        
        k = k + 1;
        XforFact(:,k) = t.get(n).img(nonZeroRays);
        
        
    end
    
    
end

fprintf( 'X contains %d columns\n', k );

if DEBUG
    figure; imshow( mlaFromLF( reshape2LF( sum(X_,2), lf_size, nonZeroRays  ), false ), [] );
end

%% delete some things to free memory
clear t;


%%
method = 'default';

%% FACTORIZE
tic;
[Dnmf] = factorization( XforFact, numberNeurons, [], nonZeroRays, method );
nmftime = toc;
fprintf('Factorization took: %d minutes and %f seconds\n',floor(nmftime/60),rem(nmftime,60));

%% STORE AND CHECK results


parentFolder = scanning_dir;
folderName = [ ...
    'neurons_',  num2str(numberNeurons), ...
    '_nmf_', method ];
path = fullfile( parentFolder, factType, folderName );

if 7~=exist(path,'dir')
    mkdir(path);
end

workspace_filename = fullfile( path, 'workspace.mat' );
save(workspace_filename, '-v7.3');

% CHECK QUALITY:
% mapping between factorization and GT
[dist,ratio,nn] = dictdist(Dexpect( nonZeroRays, : ),Dnmf( :, : ),0.0001);
if~( length( unique(nn) ) == numberNeurons )
    warning( 'not all neurons have been factorized (only %d of %d)!', length(unique(nn)), numberNeurons );
end

% OUTPUT plots:
[cLF, cmap] = colorized_lf( Dnmf, nonZeroRays, lf_size );
plot_results( size(XforFact,2), 0, numberNeurons, Dnmf, nonZeroRays, lf_size, cLF, path, cmap);




