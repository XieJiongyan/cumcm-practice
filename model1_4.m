close
path = load('totalsolve/totalsolve/voyage.txt');
% path = path / pi * 180;
[pathsize, ~] = size(path);
load model1_2
path_img = zeros(pathsize, 2);
I = imread('input/showimg.png');
h = imshow(I);
[show_x, show_y, ~] = size(I);
show_rho_0 = 276;
theta2show_rho = @(theta) show_rho_0 / 30 * (90 - theta);
varphi2show_vartheta = @(varphi)varphi;
ecs2img = @(varphi, theta) [round(x_mid_img +...
    theta2rho(theta) * sind(varphi2vartheta(varphi))), ...
    round(y_mid_img - theta2rho(theta) *...
    cosd(varphi2vartheta(varphi)))];

xmid = (530 + 57) / 2 + 1;
ymid = (93 + 569)/ 2 + 1;
ecs2show = @(varphi, theta) [round(xmid + theta2show_rho(theta) * sind(varphi2show_vartheta(varphi))),...
    round(show_y - ymid - theta2show_rho(theta) * cosd(varphi2show_vartheta(varphi)))];
hold on
for i = 1 : pathsize
    path_img(i, :) = ecs2show(path(i, 1), path(i, 2));
    I(path_img(i, 1), path_img(i, 2), :) = [0, 0, 0];
    plot(path_img(i, 1), show_y - path_img(i, 2), 'r.')
end
% for x = 0 : 10 : 180
%     for y = 90 : -5 : 70
%         a = ecs2show(x, y);
%         plot(a(1), show_y - a(2), 'r.');
%     end
% end

hold off