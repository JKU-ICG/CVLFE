function [ ndifference, difference ] = similartiy_recordings( parentImg, childImg )

% compute similarity to parent! for eg. early stopping!
meanParentImg = mean(parentImg(:));
scaleToParent = meanParentImg / mean( childImg(:) );
% ABSOLUTE DIFFERENCE
difference = mean(abs(double(parentImg(:)) ...
    - ( scaleToParent .* double(childImg(:))) ));
% normalized difference
ndifference = difference/meanParentImg;


end

