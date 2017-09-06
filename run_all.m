cd( 'CVLFE' ); % go into subfolder where all functions can be found!

%% GLOBAL SETTINGS:
clear all;
global batch_scanning_dir;
batch_scanning_dir = []; % to work on existing data set this to the data folder!

global batch_params;
batch_params = struct();
batch_params.nmfType = 'nmf'; %use 'nmf_gt' to assume a perfect factorization
batch_params.sigma = 0.001; % this is the scattering coefficient used

global batch_use_batch; batch_use_batch = true;

%% SIMULATE PROBE SCANNING
if isempty( batch_scanning_dir )
    scanning_with_scattering;
end
assert( ~isempty( batch_scanning_dir ) );

%% PROCESS SCANNED PROBE AND ESTIMATE T
T_after_scanning;

%% FACTORIZE
if ~strcmpi( batch_params.nmfType, 'nmf_gt')
    factorize_scanning;
end

%% COMPUTE ILLUMINATION PATTERNS
compute_illum_and_reproj;
%compute_masked_illum_and_reproj;