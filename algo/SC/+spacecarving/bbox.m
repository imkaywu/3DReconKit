function [xlim, ylim, zlim] = bbox(dir, name)

    pts = ply_read_vnc(sprintf('%s/%s_mvs_screened.ply', dir, name));
    xlim = [min(pts(1, :)), max(pts(1, :))];
    ylim = [min(pts(2, :)), max(pts(2, :))];
    zlim = [min(pts(3, :)), max(pts(3, :))];
    ratio = 0.2;
    xrange = ratio * diff(xlim);
    yrange = ratio * diff(ylim);
    zrange = ratio * diff(zlim);
    xlim = [xlim(1) - xrange, xlim(2) + xrange];
    ylim = [ylim(1) - yrange, ylim(2) + yrange];
    zlim = [zlim(1) - zrange, zlim(2) + zrange];
    
    figure(3);
    plot3(pts(1, :), pts(2, :), pts(3, :), 'r.'); hold on;
    corners = [xlim(1), xlim(1), xlim(1), xlim(1), xlim(2), xlim(2), xlim(2), xlim(2);
               ylim(1), ylim(1), ylim(2), ylim(2), ylim(1), ylim(1), ylim(2), ylim(2);
               zlim(1), zlim(2), zlim(1), zlim(2), zlim(1), zlim(2), zlim(1), zlim(2)];
    plot3(corners(1, :), corners(2, :), corners(3, :), 'b-');
    
    clear pts;
end
