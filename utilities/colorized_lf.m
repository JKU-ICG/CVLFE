function [colorLF, cmap, idLF] = colorized_lf( Dnmf, nonzeroRays, lf_size, normalize, threshold, input_colormap )
%PLOT_RESULTS Summary of this function goes here
%   Detailed explanation goes here
eps = 0.01;
imshowScale = 1;
idLF = zeros( lf_size, 'single' );

if nargin < 4
    normalize = true;
end
if nargin < 5
    threshold = false;
end
if isempty( nonzeroRays )
    nonzeroRays = true( lf_size );
end

numberNeurons = size(Dnmf,2);
if nargin < 6
    
    use_colors = colorcube(max(numberNeurons+1,8)); % max with 8 to avoid gray colors!!!
    use_colors(sum( use_colors, 2 )==0,:) = []; %delete black color!
    %cmap = colormap(use_colors);
    cmap = use_colors;
else
    cmap = input_colormap;
end

%FigH = figure('units','normalized','outerposition',[0 0 1 1]);
%set(FigH, 'NumberTitle', 'off', 'Name', name);

colorLF = [];


for m = 1:numberNeurons
    
    lf = zeros(lf_size);
    lf( nonzeroRays ) = Dnmf(:,(m));
    %lf = Dnmf(:,(m));
    if threshold
        threshold_lf = lf(:) >= (max(lf(:))*0.1);
        lf( threshold_lf ) = 1.0;
        lf( ~threshold_lf ) = 0.0;
        idLF( threshold_lf ) = m;
    end
    c_lf = permute( lf, [ 1 2 5 3 4 ] );
    c_lf = repmat( c_lf, [ 1 1 3 1 1 ] ); % make color
    
    if normalize
        % normalize lf individually
        c_lf = c_lf./max(c_lf(:));
    end
    
    % apply colormap
    for c = 1:3
        c_lf(:,:,c,:,:) = c_lf(:,:,c,:,:) .* cmap( m, c );
    end
    
    if isempty( colorLF )
        colorLF = c_lf;
    else
        colorLF = colorLF + c_lf;
    end
    
    %         estMLA = mlaFromLF( permute( lfKsvd, [1 2 5 3 4] ));
    %         imshow( imresize(estMLA,imshowScale), [], 'Border','tight' );
    %         [x,y] = find( estMLA>eps ) ;
    %         estCenterOfMassXY = [mean(x) mean(y)]*imshowScale ;
    %         hold on;
    %         plot( estCenterOfMassXY(2), estCenterOfMassXY(1), 'r*' );
    %         title( [ 'NMF - neuron ' num2str(m) ] );
    %
    %         if ~exist('estCenterOfMassXY_array', 'var')
    %             estCenterOfMassXY_array = estCenterOfMassXY;
    %         else
    %             estCenterOfMassXY_array = [estCenterOfMassXY_array; estCenterOfMassXY];
    %         end
end

if ~threshold && normalize
    % convert to uint8
    colorLF = colorLF .* 255;
    %colorLF = colorLF * 255;
    colorLF = uint8(colorLF);
elseif threshold
    colorLF = uint8(colorLF.*255);
end

end

