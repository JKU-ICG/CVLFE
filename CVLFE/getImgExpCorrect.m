function [ img ] = getImgExpCorrect( t, t_id )
%GETEXPCORRECT Summary of this function goes here
%   Detailed explanation goes here

    img = double( t.get(t_id).img ) ./ t.get(t_id).exposure;

end

