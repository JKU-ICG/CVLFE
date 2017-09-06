function figh = plot_lfs(Ds, lf_size, names, figh, nonZeroRays )
%PLOT_RESULTS plot results of nmf factorization


imshowScale = 1;

%set(figh, 'NumberTitle', 'off', 'Name', name);

if nargin < 3 || isempty( names )
    names = mat2cell( 1:size(Ds,2), [1], ones(size(Ds,2),1) );
end
if nargin < 4
    figh = figure( );
else
    figure( figh );
end
if nargin < 5
   nonZeroRays = []; 
end



sb_y = ceil( sqrt( size(Ds,2) ) );
sb_x = ceil( size(Ds,2) / sb_y );
sb_y = ceil( size(Ds,2) / sb_x );
for m = 1:size(Ds,2)

        
        subplot( sb_x, sb_y, m );
        
        estMLA = mlaFromLF( reshape_to_lf( Ds(:,(m)), lf_size, nonZeroRays ), false );
        imshow( imresize( estMLA, imshowScale), [] );
        

        if isstr( names{m} )
            title( [ names{m} ] );
        else
            title( [ num2str(names{m}) ] );
        end
        %end
        
        

end

drawnow();



end

