function [Y,numIter,tElapsed]=seminmfnnlstest(X,outTrain)
% Project test samples into the feature space, this function is called by
% function featureExtractionTest.
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

tStart=tic;
A=outTrain.factors{1};
% option=outTrain.option;
Y=fcnnls(A,X);
numIter=1;
tElapsed=toc(tStart);
end
