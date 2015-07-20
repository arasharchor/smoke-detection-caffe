function fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,header,str,math)
    font_size = 12;
    nl = sprintf('\n');
    xlabel_offset = 10;
    
    subplot(img_rows,img_cols,fig_idx)
    imshow(I)
    if(~isempty(header))
        title(header)
    end
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    fig_idx = fig_idx + 1;
end

