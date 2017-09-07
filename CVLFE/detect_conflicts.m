function [ n_conflicting_rays ] = detect_conflicts( img1, img2, nonZeroRays, bg_level, noIllum, fullIllum )

    % threshold
    [~,tImg1] = auto_threshold( img1, nonZeroRays, bg_level );
    [~,tImg2] = auto_threshold( img2, nonZeroRays, bg_level );
    
    
    n_conflicting_rays = tImg1 & tImg2;


end

