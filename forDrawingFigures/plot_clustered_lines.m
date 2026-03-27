function plot_clustered_lines(vpInfo, LineWidth)

% plot clustered lines
for k = 1:vpInfo(1).n
    linePixelPts = vpInfo(1).line(k).data;
    pt1_pixel = linePixelPts(1:2);
    pt2_pixel = linePixelPts(3:4);
    
    % plot clustered lines
    plot([pt1_pixel(1),pt2_pixel(1)],[pt1_pixel(2),pt2_pixel(2)],'r','LineWidth',LineWidth);
end
for k = 1:vpInfo(2).n
    linePixelPts = vpInfo(2).line(k).data;
    pt1_pixel = linePixelPts(1:2);
    pt2_pixel = linePixelPts(3:4);
    
    % plot clustered lines
    plot([pt1_pixel(1),pt2_pixel(1)],[pt1_pixel(2),pt2_pixel(2)],'g','LineWidth',LineWidth);
end
for k = 1:vpInfo(3).n
    linePixelPts = vpInfo(3).line(k).data;
    pt1_pixel = linePixelPts(1:2);
    pt2_pixel = linePixelPts(3:4);
    
    % plot clustered lines
    plot([pt1_pixel(1),pt2_pixel(1)],[pt1_pixel(2),pt2_pixel(2)],'b','LineWidth',LineWidth);
end


end

