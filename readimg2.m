close all
I = imread('input/seaice/CICE_combine_thick_SM_EN_20200701.png');
h = imshow(I);
y = 575;
xstart = 60;
xend = 572;
color_type = 36;
gap = (xend - xstart)/color_type - 1;
mymap = zeros(3, color_type);
for i = 0:color_type  - 1
    xnow = ceil(xstart + i * gap); 
    mymap(:, i + 1) = I(y, xnow, :);
end
figure;
mymap_ = double(mymap') / 256.0;
colormap(mymap_);
colorbar;
mid_y = 251;
mid_x = 320;
x_left = 144;
x_right = 459;
y_top = 53;
y_bottom = 405;
x_mid_img = mid_x - x_left;
y_mid_img = y_bottom - mid_y;
rho_0 = 517 - mid_y;
save readimg2.mat x_mid_img y_mid_img rho_0...
    mymap_ mymap color_type
heights = zeros(y_bottom - y_top, x_right - x_left);
for ix = x_left + 1 : x_right
    for iy = y_top + 1 : y_bottom
        for i = color_type - 1:-1:0
            cv = reshape(double(I(iy, ix, :)), 3, 1) - mymap(:, i + 1);
            if cv' * cv < 400
                heights(y_bottom - iy + 1, ix - x_left)...
                    = i / color_type * (4.9 - 0.1) + 0.1;
                break;
            end
        end
        if heights(y_bottom - iy + 1, ix - x_left) == 0
            heights(y_bottom - iy + 1, ix - x_left) = NaN;
        end
    end
end
save heights;
figure;
[C, h] = contourf(heights, 0.1 : (4.9 - 0.1) /...
    color_type : 4.9);
set(h,'LineColor','none')
colormap(mymap_)
colorbar;