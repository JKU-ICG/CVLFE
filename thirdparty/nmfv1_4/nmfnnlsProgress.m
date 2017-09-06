function [A,Y,numIter,tElapsed,finalResidual,finalResiduals_everyIter,finalResiduals_20iter,A_every10iter]=nmfnnlsProgress(X,k,option)
% NMF based on NNLS: X=AY, s.t. X,A,Y>=0.
% Definition:
%     [A,Y,numIter,tElapsed,finalResidual]=nmfnnls(X,k)
%     [A,Y,numIter,tElapsed,finalResidual]=nmfnnls(X,k,option)
% X: non-negative matrix, dataset to factorize, each column is a sample, and each row is a feature.
% k: scalar, number of clusters.
% option: struct:
% option.iter: max number of interations. The default is 1000.
% option.dis: boolen scalar, It could be 
%     false: not display information,
%     true: display (default).
% option.residual: the threshold of the fitting residual to terminate. 
%     If the ||X-XfitThis||<=option.residual, then halt. The default is 1e-4.
% option.tof: if ||XfitPrevious-XfitThis||<=option.tof, then halt. The default is 1e-4.
% A: matrix, the basis matrix.
% Y: matrix, the coefficient matrix.
% numIter: scalar, the number of iterations.
% tElapsed: scalar, the computing time used.
% finalResidual: scalar, the fitting residual.
% References:
%  [1]\bibitem{NMF_ANLS_Kim2008}
%     H. Kim and H. Park,
%     ``Nonnegative matrix factorization based on alternating nonnegativity constrained least squares and active set method,''
%     {\it SIAM J. on Matrix Analysis and Applications},
%     vol. 30, no. 2, pp. 713-730, 2008.
%  [2]\bibitem{NMF_Sparse_Kim2007}
%     H. Kim and H. Park,
%     ``Sparse non-negatice matrix factorization via alternating non-negative-constrained least squares for microarray data analysis,''
%     {\it Bioinformatics},
%     vol. 23, no. 12, pp. 1495-1502, 2007.
%%%%
% Copyright (C) <2012>  <Yifeng Li>
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 
% Contact Information:
% Yifeng Li
% University of Windsor
% li11112c@uwindsor.ca; yifeng.li.cn@gmail.com
% May 01, 2011
%%%%

[r,c]=size(X); % c is # of samples, r is # of features

tStart=tic;
optionDefault.iter=200;
optionDefault.dis=true;
optionDefault.residual=1e-4;
optionDefault.tof=1e-4;
%optionDefault.initial_guess = rand( r, k );

if nargin<3
   option=optionDefault;
else
    option=mergeOption(option,optionDefault);
end

if ~isfield( option, 'initial_guess' ) || isempty(option.initial_guess)
   option.initial_guess = rand( r, k );
end

%% 
if exist( 'AdvancedTextProgressBar', 'class' )
    progBar = AdvancedTextProgressBar();
    progBar.SetMaxCount( option.iter );
    progBar.UpdateText( 'nmf: factorizing ' );
    progBar.UpdateProgress( 0 );
else
    progBar = [];
end
progBar = [];

% iter: number of iterations
[r,c]=size(X); % c is # of samples, r is # of features
A=option.initial_guess;
XfitPrevious=Inf;

finalResiduals_everyIter = [];
finalResiduals_20iter = [];
A_every10iter = [];

A=normc(A);
Y=kfcnnls(A,X);
XfitThis=A*Y;
XfitPrevious=XfitThis;
curRes=norm(X-XfitThis,'fro');
finalResiduals_everyIter = [finalResiduals_everyIter curRes];
A_every10iter = cat(3,A_every10iter,A);

  
for i=1:option.iter
    
    % David switched ordering here! ... hope it works!
    Y=kfcnnls(A,X);
    A=kfcnnls(Y',X');
    A=A';
    A=normc(A);
    
    % We compute the final residual every iteration and plot it after (in
    % another function) to see the behavior
    XfitThis=A*Y;
    fitRes=matrixNorm(XfitPrevious-XfitThis);
    XfitPrevious=XfitThis;
    curRes=norm(X-XfitThis,'fro');
    finalResiduals_everyIter = [finalResiduals_everyIter curRes];
        
    if mod(i-1,5)==0 || i==option.iter
        if option.dis
            if isempty(progBar)
                disp(['Iterating >>>>>> ', num2str(i),'th']);
            else
                progBar.UpdateText( [ 'nmf: factorizing iteration ' num2str(i) ' ' ] );
            end
        end
        
        A_every10iter = cat(3,A_every10iter,A);
        
%         XfitThis=A*Y;
%         fitRes=matrixNorm(XfitPrevious-XfitThis);
%         XfitPrevious=XfitThis;
%         curRes=norm(X-XfitThis,'fro');

        finalResiduals_20iter = [finalResiduals_20iter curRes];
        if option.tof>=fitRes || option.residual>=curRes || i==option.iter
            s = sprintf('NNLS based NMF successes! \n # of iterations is %0.0d. \n The final residual is %0.4d.',i,curRes);
            disp(s);
            numIter=i;
            finalResidual=curRes;
            break;
        end
    end
    if ~isempty(progBar), progBar.UpdateProgress( i ); end;
end
tElapsed=toc(tStart);
if ~isempty(progBar), progBar.Finish(); end;
end

