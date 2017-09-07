function [ img ] = getImgExpCorrect( t, t_id )

    img = double( t.get(t_id).img ) ./ t.get(t_id).exposure;

end

