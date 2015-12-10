function tiles = img2Tiles( img,num_row_tiles,num_col_tiles )
    row_size = round(size(img,1)/num_row_tiles);
    col_size = round(size(img,2)/num_col_tiles);
    tiles = mat2cell(img,...
        [ones(1,num_row_tiles-1)*row_size,size(img,1)-(num_row_tiles-1)*row_size],...
        [ones(1,num_col_tiles-1)*col_size,size(img,2)-(num_col_tiles-1)*col_size],...
        size(img,3));
end
