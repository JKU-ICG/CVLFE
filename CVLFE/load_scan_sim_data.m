

global batch_scanning_dir;
global batch_use_batch;
if ~batch_use_batch
    scanning_dir = ''; % set manually
    nmfType = ''; % set manually
    error( 'not implemented!' );
else
    global batch_params;
    scanning_dir = batch_scanning_dir;
    nmfType = batch_params.nmfType;
end

lighttransport_folder = scanning_dir;
lighttransportFileName = fullfile(lighttransport_folder,'lighttransport.mat');
if ~exist( lighttransportFileName, 'file' )
    error( 'Lighttransport File "%s" does not exist!', lighttransportFileName );
end
lighttransport =  matfile( lighttransportFileName ,'Writable', false);

scanFileName = fullfile(scanning_dir,'workspace.mat');
if ~exist( scanFileName, 'file' )
    error( 'Scan File "%s" does not exist!', scanFileName );
end

scanMfile =  matfile(scanFileName,'Writable', false);
gtD = scanMfile.Dexpect; full_lf_size = scanMfile.full_lf_size; A = scanMfile.A;

if strcmpi( nmfType, 'nmf_gt' ) 
    % special case: IGNORE NMF (errors maybe)
    nmf = struct( 'Dnmf', gtD, 'nonZeroRays', true( size(gtD,1),1 ), 'lf_size', full_lf_size );
else
    nmfFileName = fullfile( scanning_dir, nmfType, sprintf( 'neurons_%d_nmf_%s', numberNeurons, nmfMethod ), ...
        'workspace.mat' );
    if ~exist( nmfFileName, 'file' )
        error( 'NMF File "%s" does not exist!', nmfFileName );
    end
    nmf = matfile( nmfFileName, 'Writable', false );
    % usage nmf: Dnmf, nonZeroRays, lf_size
end