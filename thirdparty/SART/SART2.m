% run a number of SART updates 
function x = SART2(T, b, lb, ub, x0, maxIters, disp)
    
    if nargin < 7
        disp = false;
    end
    if disp
       errs = ones(maxIters,1);
       addpath( '../thirdparty/fig/' ); % silent figure updates
       figure = @fig; % silent figure updates
       h_fig = figure();
    end
        
    Tt = T';
    % lb and up lower and upper bounds
    % x0 initial guess
    % compute weights 
    W = T*ones(size(x0)); 
    W(W~=0) = 1 ./ W(W~=0);
    
    V = Tt*ones(size(W)); 
    V(V~=0) = 1 ./ V(V~=0);
    
    % initialize result
    x = x0;
    
    % run SART iterations
    for k=1:maxIters
        if disp
           %fprintf( 'SART: %d/%d\n', k, maxIters ); 
           
           curr_error = (b-T*x);
           curr_error = mean( curr_error(:).^2 ); % MSE!
           errs(k) = curr_error;
           figure( h_fig );
           plot( 1:k, errs(1:k) ); drawnow();
        end
        % update x
        x = x + V .* (Tt*( W .* (b-T*x)));
        % project back into feasible range
        x(x<lb) = lb(x<lb); 
        x(x>ub) = ub(x>ub);
    end

end