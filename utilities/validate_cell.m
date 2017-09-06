function [ success_accessing_or_not_empty ] = validate_cell( variable, i_s,i_t,i_u,i_v  )
%VALIDATE_CELL Summary of this function goes here
%   Detailed explanation goes here

try
    if nargin == 5
        success_accessing_or_not_empty = ~isempty( variable{i_s,i_t,i_u,i_v} ); % try to avoid error!
    elseif nargin == 4
        success_accessing_or_not_empty = ~isempty( variable{i_s,i_t,i_u} ); % try to avoid error!
    elseif nargin == 3
        success_accessing_or_not_empty = ~isempty( variable{i_s,i_t} ); % try to avoid error!
    elseif nargin == 2
        success_accessing_or_not_empty = ~isempty( variable{i_s} ); % try to avoid error!
    end
    
catch exception
    success_accessing_or_not_empty = false;
end


end

