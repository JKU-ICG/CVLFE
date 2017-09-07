function [ img, tImg1 ] = auto_threshold( img1, nonZeroRays, bg_level, thresFact )
    meanImg1 = mean( img1( (img1(:) > bg_level) & nonZeroRays(:) ) );
    
    if nargin < 4
        % threshold
        thresFact = 0.5;
    end
    
    % logical array
    tImg1 = ( ( img1(:) > (meanImg1*thresFact) ) & nonZeroRays(:) );

    % thresholded image (low values are set to zero)
    img = img1;
    img(~tImg1) = 0;

end

