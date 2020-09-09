clear
load model1.mat 
load('readimg2.mat')
load fiximg
varphi2vartheta = @(varphi) varphi;
theta2rho = @(theta) rho_0 / 30 * (90 - theta);
ecs2img = @(varphi, theta) [round(x_mid_img +...
    theta2rho(theta) * sind(varphi2vartheta(varphi))), ...
    round(y_mid_img - theta2rho(theta) *...
    cosd(varphi2vartheta(varphi)))];
imgcs = ecs2img(start_place(1), start_place(2));
save model1_2.mat ecs2img varphi2vartheta theta2rho
figure;
[C, h] = contourf(Hs, 0 : 0.2 : 4);
set(gcf,'unit',...
    'normalized','position',[0,0,N / 1000,M / 1000]);
set(h,'LineColor','none')
colormap(mymap_)
colorbar;

polor = ecs2img(0, 90);
hold on
scatter(imgcs(1), imgcs(2), 'o');
scatter(polor(1), polor(2), 'o');

for t_theta = 85 : -5 : 70
    for t_varphi = -10 : 10 : 180
        t = ecs2img(t_varphi, t_theta);
        scatter(t(1), t(2), 'o');
    end
end