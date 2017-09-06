function [Dnmf,alphaNmf] = factorization(X_, numberNeurons, Dexpect, nonzeroRays, lf_size, method )
    %FACTORIZATION_TESTS Summary of this function goes here
    %   Detailed explanation goes here

    if nargin < 6
       method = 'default'; 
    end
    
    


    %% Run non-negative matrix factorization:
    % STATISTIC TOOLBOX: [W,H] = nnmf(X_,numberNeurons)
    addpath( '../thirdparty/nmfv1_4' );
    
    options = struct();
    
    switch( method )
        case 'sparse'
            options.algorithm = 'sparsenmf2rule';
            options.optionnmf = struct();
            options.optionnmf.iter = 100000;
            options.optionnmf.alpha2 = 1; % smoothness of D atoms
            options.optionnmf.alpha1 = 0.5; %      sparseness of D atoms
            options.optionnmf.lambda2= 0; %      smoothness of Y atoms
            options.optionnmf.lambda1= 0.0; %    sparseness of Y atoms
            [Dnmf,alphaNmf,numIter,tElapsed,finalResidual] =sparsenmf2rule(X_, numberNeurons, options.optionnmf);

        otherwise 'default nfm'
            [Dnmf,alphaNmf,numIter,tElapsed,finalResidual] = nmf(X_, numberNeurons);
            I = Dnmf * alphaNmf;
            % Plot D*A results vs X results
            % plot_DA_results(lf_size, I, nonzeroRays, X_, numberNeurons);
    
    end
   
    
end

