close all
I = imread('input/cn_MITgcm_Arctic_it_surface_2020070100_024.jpg');
h = imshow(I);
y = 925;
xstart = 61;
xend = 962;
gap = (xend - xstart)/19;
mymap = zeros(3, 20);
for i = 0:19
    xnow = ceil(xstart + i * gap); 
    mymap(:, i + 1) = I(y, xnow, :);
end
figure;
mymap_ = double(mymap') / 256.0;
colormap(mymap_);
colorbar;
x_left = 120;
x_right = 755;
y_top = 110;
y_bottom = 860;
heights = zeros(y_bottom - y_top, x_right - x_left);
for ix = x_left + 1: x_right
    for iy = y_top + 1: y_bottom
        for i = 19:-1:0
            cv = reshape(double(I(iy, ix, :)), 3, 1) - mymap(:, i + 1);
            if cv' * cv < 200
                heights(y_bottom - iy + 1, ix - x_left) = i * 0.2 + 0.1;
                break;
            end
        end
    end
end
save heights;
figure;
contourf(heights)
colorbar;