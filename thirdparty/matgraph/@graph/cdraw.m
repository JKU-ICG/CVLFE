function cdraw(g,coloring,line_style,color_matrix)
% cdraw(g,coloring) -- draw g with a given vertex coloring
% If no coloring is specified, the default is 'greedy'. 
%
% cdraw(g,coloring,line_style) --- lines have given line_style. If this is
% not given, the style '-' is used (solid lines). Try ':' for dotted lines.
%
% cdraw(g,coloring,line_style,color_matrix) --- specify the colors for the
% vertices. color_matrix is an nc-by-3 matrix of RGB values where nc is the
% number of colors in the coloring. The default is hsv(nc). 
%
% color_matrix can also be a string of MATLAB color specifiers, e.g., 
% cdraw(g,color(g),'-','kwrgb') will draw vertices in color class 1 with
% color 'k' (black), vertices in color class 2 'w' (white), etc. 
%
% In either case (matrix or letter string) the user must make sure the
% matrix contains sufficiently many colors.
% 
% See also draw, ldraw, and ndraw.
%
% Original author: Brian Towne; modifications by ERS.

edge_color = 'k';
vertex_color = 'k';
r = 0.15;

if nargin < 3
    line_style = '-';
end

if nargin < 2
    coloring = color(g,'greedy');
end

n = nv(g);
n2 = nv(coloring);

if nargin < 4
    color_matrix = hsv(np(coloring));
end

if ~(n==n2)
    error('Graph and coloring must have equal number of vertices.')
end

if ~hasxy(g)
    embed(g);
end

xy = getxy(g);

% first draw the edges
elist = edges(g);
for j=1:ne(g)
    u = elist(j,1);
    v = elist(j,2);
    x = xy([u,v],1);
    y = xy([u,v],2);
    line(x,y,'Color', edge_color,'LineStyle',line_style);
end


% Now draw the vertices by color class
color_classes = parts(coloring);
num_colors = np(coloring);

for i=1:num_colors
    color_class_size = size(color_classes{i},2);
    if ischar(color_matrix)
        vertex_fill = color_matrix(i) ;
    else
        vertex_fill = color_matrix(i,:);
    end
    for j=1:color_class_size
        v = color_classes{i}(j);
        x = xy(v,1);
        y = xy(v,2);
        rectangle('Position', [x-r/2, y-r/2, r, r],...
                  'Curvature', [1 1], ...
                  'EdgeColor', vertex_color, ...
                  'FaceColor', vertex_fill);    
    end
end    

axis equal
axis off
