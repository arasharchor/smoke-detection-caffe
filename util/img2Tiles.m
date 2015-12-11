function [ tiles,num_tiles ] = img2Tiles( img )
    narginchk(0,1)
    
    num_tiles = 16;
    
    if(nargin==0)
        tiles = 0;
        return;
    end

    % type I tiles
    num_row_tiles = 4;
    num_col_tiles = 4;
    row_size = round(size(img,1)/num_row_tiles);
    col_size = round(size(img,2)/num_col_tiles);
    tiles = mat2cell(img,...
        [ones(1,num_row_tiles-1)*row_size,size(img,1)-(num_row_tiles-1)*row_size],...
        [ones(1,num_col_tiles-1)*col_size,size(img,2)-(num_col_tiles-1)*col_size],...
        size(img,3));
    tiles = tiles(:);
    
    % type II tiles
end

