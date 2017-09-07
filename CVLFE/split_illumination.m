function [ illuminations, lfs ] = split_illumination( illumination_parent, full_lf_size, varargin )
%CREATE_HIERACHICAL_ILLUMINATION



%% INPUT handling

p = inputParser();
p.addRequired( 'illumination_parent' );
p.addRequired( 'full_lf_size' );
p.addParameter( 'use_st_only', false );
p.addParameter( 'use_uv_only', false );
p.addParameter( 'valid_lf', [] );

p.parse( illumination_parent, full_lf_size, varargin{:} );

DEBUG = false;
DEBUG_PLOT = false;
use_st_only = p.Results.use_st_only;
use_uv_only = p.Results.use_uv_only;
if use_st_only && use_uv_only
   error( 'use_st_only and use_uv_only cannot be used togehter!' );
end

%%

illuminations = {};
lfs = {};

lf_size = [ numel(illumination_parent{1}), numel(illumination_parent{2}), ...
    numel(illumination_parent{3}), numel(illumination_parent{4}) ];

if prod(lf_size) <= 1 % we cannot split anything!!!
   return; % STOP!    
end

half_size = ceil(lf_size./2);
stuv_loop = { 1:2, 1:2, 1:2, 1:2 };
if use_uv_only
   half_size(1:2) = lf_size(1:2); 
   stuv_loop{1} = 1; stuv_loop{2} = 1; 
   if prod(lf_size(3:4)) <= 1 % we cannot split anything!!!
       return; % STOP!    
   end
end
if use_st_only 
   half_size(3:4) = lf_size(3:4); 
   stuv_loop{3} = 1; stuv_loop{4} = 1;
   if prod(lf_size(1:2)) <= 1 % we cannot split anything!!!
       return; % STOP!    
   end
end

if DEBUG
    debug_lf = zeros( full_lf_size );
    
    if DEBUG_PLOT
        h_fig1 = figure(1);
        h_fig2 = figure(2);
    end
end
    % SINGLE SPLIT
    
    i = 1;
    for s_split = stuv_loop{1}
    for t_split = stuv_loop{2}
    for u_split = stuv_loop{3}
    for v_split = stuv_loop{4}
    
        positions = { ...
            ((s_split-1)*half_size(1)+1):min(lf_size(1),s_split*half_size(1)), ...
            ((t_split-1)*half_size(2)+1):min(lf_size(2),t_split*half_size(2)), ...
            ((u_split-1)*half_size(3)+1):min(lf_size(3),u_split*half_size(3)), ...
            ((v_split-1)*half_size(4)+1):min(lf_size(4),v_split*half_size(4)) };
        
        if isempty( positions{1} ) || isempty( positions{2} ) ...
                || isempty( positions{3} ) || isempty( positions{4} )
            %illuminations{s_split,t_split,u_split,v_split} = []; % set empty!
            continue; % skip the rest of the loop!
        end
        

       
        pos_in_parent = { illumination_parent{1}(positions{1}), illumination_parent{2}(positions{2}), ...
            illumination_parent{3}(positions{3}), illumination_parent{4}(positions{4}) };
        
        
        lf = zeros( full_lf_size );
        lf(pos_in_parent{1},pos_in_parent{2},pos_in_parent{3},pos_in_parent{4}) = 1.0;
        
        
        % VALIDATE if positions are valid
        if ~isempty( p.Results.valid_lf ) ...
                && ~any( p.Results.valid_lf( lf>0 ) ) % no valid idx
            continue; % skip the rest (so don't store!!)
        end

        % STORE:
        illuminations{s_split,t_split,u_split,v_split} = pos_in_parent;
        lfs{s_split,t_split,u_split,v_split} = lf;
        
        
        if DEBUG          
           debug_lf = debug_lf + lf;
           if DEBUG_PLOT
               figure( h_fig1 ); 
               subplot( 1,2,1 ); imshow( mlaFromLF( lf, false ), [] ); title( 'current illum' );
               subplot( 1,2,2 ); imshow( mlaFromLF( debug_lf, false ), [0 max(debug_lf(:))] ); title( 'sum' );
               drawnow();
           end
        end
    
        % increaese loop counter at the end of loop!
        i = i + 1;
        
    end
    end
    end
    end
    
    if DEBUG
        debug_sum = zeros( full_lf_size );
        % check if children sum up to parent
        for i_s = 1:size( illuminations, 1 )
        for i_t = 1:size( illuminations, 2 )
        for i_u = 1:size( illuminations, 3 )
        for i_v = 1:size( illuminations, 4 )
            child = illuminations{i_s,i_t,i_u,i_v};
            if ~isempty( child )
                lf = zeros( full_lf_size );
                cpositions = child;
                lf(cpositions{1},cpositions{2},cpositions{3},cpositions{4}) = 1.0;
                debug_sum = debug_sum + lf;  
            end
        end
        end
        end
        end
        %compare to parent
        lf = zeros( full_lf_size ); ppositions = illumination_parent;
        lf(ppositions{1},ppositions{2},ppositions{3},ppositions{4}) = 1.0;
        if DEBUG_PLOT
            figure( h_fig2 );
            subplot(1,2,1); imshow( mlaFromLF( lf, false ), [0 1] ); title( 'parent' );
            subplot(1,2,2); imshow( mlaFromLF( debug_sum, false ), [0 1] ); title( 'sum' );
            drawnow();
        end
        assert( isequal( debug_sum, lf ) );
    end
    
    
end


