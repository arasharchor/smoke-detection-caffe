function fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,header,str,math)
    font_size = 11;
    nl = sprintf('\n');
    xlabel_offset = 15;
    
    [c,r] = ind2sub([img_cols img_rows],fig_idx);
    hspan = 0.005;
    vspan = 0.1;
    subplot('Position',[(c-1)/img_cols+hspan/2, 1-(r)/img_rows+vspan/1.5, 1/img_cols-hspan, 1/img_rows-vspan])
%     subplot(img_rows,img_cols,fig_idx);
    imshow(I,'border','tight')
    if(~isempty(header))
        title(header)
    end
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    fig_idx = fig_idx + 1;
end

