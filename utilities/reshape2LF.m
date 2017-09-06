function [ r ] = reshape2LF(  fullIllum, full_lf_size, nonZeroRays  )
%RESHAPE_TO_LF Summary of this function goes here
%   Detailed explanation goes here,

    if nargin > 2 && ~isempty( nonZeroRays )
        r = zeros( full_lf_size ); 
        r(nonZeroRays) = fullIllum(:);
    else
        r = reshape( fullIllum, full_lf_size );
    end


end

