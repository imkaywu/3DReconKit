% empty or filled circle

function img_circ = imcircle(sz, c, r, t)
    if nargin == 3
        t = 0;
    end

    img_circ = zeros(sz, 'uint8');
    x = repmat(1 : sz(2), sz(1), 1);
    y = repmat((1 : sz(1))', 1, sz(2));
    dist = sqrt((x - c(1)).^2 + (y - c(2)).^2);
    
    switch t
        case 0
            % empty circle
            ind_in_circ = dist <= r & dist > r - 0.5;
            img_circ(ind_in_circ) = 255;
            ind_out_circ = dist > r & dist < r + 0.5;
            img_circ(ind_out_circ) = uint8(255.0 * (r + 0.5 - dist(ind_out_circ)) / 0.5);
        case 1
            % filled circle
            ind_in_circ = dist <= r;
            img_circ(ind_in_circ) = 255;
            ind_on_circ = dist > r & dist - 0.5 < r;
            img_circ(ind_on_circ) = uint8(255.0 * (r + 0.5 - dist(ind_on_circ)) / 0.5);
    end
end