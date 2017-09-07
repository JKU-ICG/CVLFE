function [SGT_Fig, FigH] = plot_results( numberOfIllumination, percentageOfLight, numberNeurons, Dnmf, nonzeroRays, lf_size, GT, folder, cmap )

    eps = 5;
    imshowScale = 1;
    name = [ 'Number of neurons :  ' num2str(numberNeurons),' / Number of illuminations :  ' num2str(numberOfIllumination) ];

    FigH = figure('units','normalized','outerposition',[0 0 1 1]);
    set(FigH, 'NumberTitle', 'off', 'Name', name);
    
    sp1 = round(sqrt( numberNeurons ));
    sp2 = ceil( numberNeurons / sp1 );
    sp1 = ceil( numberNeurons / sp2 );

    for m = 1:numberNeurons

        subplot( sp1, sp2, m );
        lfKsvd = zeros(lf_size);
        lfKsvd( nonzeroRays ) = Dnmf(:,(m));
        %lfKsvd = Dnmf(:,(m));
        estMLA = mlaFromLF( permute( lfKsvd, [1 2 5 3 4] ));
        meanMax = sort( Dnmf(:,(m)), 'descend'  ); meanMax = median( meanMax(1:100) ); % maximum without outliers!
        imshow( estMLA, [0 meanMax], 'Border','tight' );
        %imshow( imresize(estMLA,imshowScale), [], 'Border','tight' );
        [x,y] = find( estMLA>eps ) ;
        estCenterOfMassXY = [mean(x) mean(y)]*imshowScale ;
        hold on;
        plot( estCenterOfMassXY(2), estCenterOfMassXY(1), 'r*' );
        title( [ 'Neuron ' num2str(m) ] );
        
        if ~exist('estCenterOfMassXY_array', 'var')
            estCenterOfMassXY_array = estCenterOfMassXY;
        else
            estCenterOfMassXY_array = [estCenterOfMassXY_array; estCenterOfMassXY];
        end
    end
    
    dim = [.1 .5 .1 .5];
    fprintf(name)
    annotation('textbox',dim,'String',name,'FitBoxToText','on');


    SGT_Fig = figure('units','normalized','outerposition',[0 0 1 1]);
    set(SGT_Fig, 'NumberTitle', 'off', 'Name', 'SGT');
  
    
    if ndims( GT ) <= 4
        estMLA_GT = mlaFromLF( permute( GT, [1 2 5 3 4] ));
    else
        estMLA_GT = mlaFromLF( GT );
    end
    GT_img = estMLA_GT;

    
    [r,c] = size(estCenterOfMassXY_array);
    for row=1:r
        text_str{row} = num2str(row);
    end
    
    imshow(GT_img, [], 'Border','tight' )
    TxtH = text( estCenterOfMassXY_array(:,2), estCenterOfMassXY_array(:,1), text_str, 'color','red', 'FontSize', 20  );
    if nargin >= 9 && ~isempty(cmap)
       for i_txt = 1:length(TxtH)
          TxtH(i_txt).Color = cmap(i_txt,:); 
       end
    end

end

