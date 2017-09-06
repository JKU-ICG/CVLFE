function u = coherence_gramm(A)
% computes the coherence of a matrix based on Learning to Sense Sparse Signals: Simultaneous Sensing Matrix and Sparsifying Dictionary Optimization
% Input:  a real matrix with more than one column
% Ouput:  the mutual coherence
% based on mutual_coherence function written by Dr. Yoash Levron, Technion, Israel, 2015
% modified by Clemens Birklbauer 2016

[M N] = size(A);
if (N<2)
    disp('error - input contains only one column');
    u=NaN;   beep;    return    
end

%mm = mean(A,1);
%A = bsxfun(@minus,A,mm);

% normalize the columns
nn = sqrt(sum(A.*A,1));
if ~all(nn)
    %disp('error - input contains a zero column');
    %u=NaN;   beep;    return
    nn(nn==0) = 1.0;
end


nA = bsxfun(@rdivide,A,nn);  % normaize A

%multiply with transposed (Gramm Matrix), substract identitiy matrix
grammA = nA'*nA-eye(N);

%compute Frobeniusnorm, gordons version (Compressive Light Field Photography using Overcomplete Dictionaries and Optimized Projections)
%u = norm(grammA,'fro');

%compute mean square (average mutual coherence) (Learning to Sense Sparse Signals: Simultaneous Sensing Matrix and Sparsifying Dictionary Optimization)
u = sum(sum(grammA.*grammA))/(N*(N-1));

%u = max(max(triu(abs((nA')*nA),1))); %original mutual coherence
end