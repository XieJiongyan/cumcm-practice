load heights
load model1.mat 
load readimg2.mat
load fiximg
load model1_2.mat
[M, N] = size(heights);
rad = 3;
for ix =  M - rad:-1: 1 + rad
    for iy =  N - rad: -1 :1 + rad
        if isnan(heights(ix, iy))
            has = 0;
            for hx = ix - rad : ix + rad
                for hy = iy - rad : iy + rad
                    if ~isnan(heights(hx, hy))
                        has = has + 1;
                    end
                end
            end
            if has < 2 * rad ^ 2 + 2 * rad  + 1
                continue;
            end
            heights(ix, iy) = 0;
            use = 0;
            for bx = [-1, 1]
                for by = [-1, 1]
                    rad_ = min(3, rad);
                    if heights(ix + bx * rad_, iy + by * rad_) >= 0.1
                        use = use + 1;
                        heights(ix, iy) = heights(ix, iy) +...
                            heights(ix + bx * rad_, iy + by * rad_);
                    end
                end
            end
            if use ~= 0
                heights(ix, iy) = heights(ix, iy) / use;
            end
        end
    end
end
figure;
[C, h] = contourf(heights, 0 : 0.2 : 4);
set(gcf,'unit',...
    'normalized','position',[0,0,N / 1000,M / 1000]);
set(h,'LineColor','none')
colormap(mymap_)
colorbar;
hold on
for x = 0 : 10 : 180
    for y = 90 : -5 : 70
        a = ecs2img(x, y);
        plot(a(1), a(2), 'ro');
    end
end
a = ecs2img(-169.51572727272725,66.153587979797976)
theta2rho(66.153587979797976)
varphi2vartheta(-169.51572727272725) / 180 * pi-169.51572727272725
x_mid_img+theta2rho(66.153587979797976) * sind(varphi2vartheta(-169.51572727272725) )
hold off
Hs = heights;
save fiximg Hs N M