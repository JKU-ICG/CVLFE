function [ img ] = mlaFromLF( lf, is_color )
%MLAFROMLF compute an image from a light field

    if nargin < 2 
        is_color = true; % assume color as default
    end

    if is_color
        [W,H,c,U,V] = size(lf);
    else
        [W,H,U,V] = size(lf); c = 1;
        lf = permute( lf, [ 1 2 5 3 4 ] );
    end
    lf = permute( lf, [1 2 3 5 4] );
    img = zeros( W*V,H*U,c, class(lf) );
    
    for u = 1:U
        for v = 1:V
            img(v:V:end,u:U:end,:) = lf(:,:,:,v,u);
        end
    end


end

