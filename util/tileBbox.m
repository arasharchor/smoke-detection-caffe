function [ tile_col,tile_row,col_size,row_size ] = tileBbox( bbox_col,bbox_row,num_row_tiles,num_col_tiles )
    col_size = numel(bbox_col)/num_col_tiles;
    row_size = numel(bbox_row)/num_row_tiles;
    tile_col = mat2cell(bbox_col,1,[col_size,col_size,col_size,col_size]);
    tile_row = mat2cell(bbox_row,1,[row_size,row_size,row_size,row_size]);
end

