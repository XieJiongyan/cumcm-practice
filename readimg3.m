close all
clear
load readimg2.mat
strbe = 'input/seaice/CICE_combine_thick_SM_EN_';
dates = [30, 31, 31, 30];
strla = '';
for month = 7 : 8
    idates = month - 5;
    if month < 9
        strla = '2020';
    else
        strla = '2019';
    end
    strm = num2str(month, '%02d');
    strla = join([strla, strm], '');
    for date = 1 : 1 : dates(idates)
        close all
        strd = num2str(date, '%02d');
        strl = join([strla, strd], '');
        filename = join([strbe, strl, '.png'], '');
        I = imread(filename);
        h = imshow(I);
        mid_y = 251;
        mid_x = 320;
        x_left = 164;
        x_right = 459;
        y_top = 53;
        y_bottom = 435;
        x_mid_img = mid_x - x_left;
        y_mid_img = y_bottom - mid_y;
        rho_0 = 517 - mid_y;
        heights = zeros(y_bottom - y_top, x_right - x_left);
        for ix = x_left + 1 : x_right
            for iy = y_top + 1 : y_bottom
                for i = color_type - 1:-1:0
                    cv = reshape(double(I(iy, ix, :)), 3, 1) - mymap(:, i + 1);
                    if cv' * cv < 250
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
        figure;
        [C, h] = contourf(heights, 0.1 : (4.9 - 0.1) /...
            color_type : 4.9);
        set(h,'LineColor','none')
        colormap(mymap_)
        colorbar;
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
        Hs = heights;
        fileplace = join(['m/'...
            , strl, '.txt'], '');
  
        fid = fopen(fileplace, 'w');
        fprintf(fid, '%d %d \n ', N, M);
        fprintf(fid, '%d %d \n ', x_mid_img, y_mid_img);
        fprintf(fid, '%d \n', rho_0);
        for im = 1 : M
            for in = 1 : N
                if isnan(Hs(im, in))
                    fprintf(fid, '-1 ');
                else
                    fprintf(fid, '%.9f ', Hs(im, in));
                end
            end
            fprintf(fid, '\n');
        end
        fclose(fid);
        figure;
        [C, h] = contourf(heights, 0 : 0.2 : 4);
        set(gcf,'unit',...
            'normalized','position',[0,0,N / 1000,M / 1000]);
        set(h,'LineColor','none')
        colormap(mymap_)
        colorbar;

    end
end