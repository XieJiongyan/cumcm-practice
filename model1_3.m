clear
load model1.mat 
load readimg2.mat
load fiximg
load model1_2.mat

nodes = 100000 * ones(x_size, y_size);
xstart = varphi2x(start_place(1));
ystart = theta2y(start_place(2));
xend = varphi2x(end_place(1));
yend = theta2y(end_place(2));
fid = fopen('Dijskra/Dijskra/20200701.txt', 'w');
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

fid = fopen('Dijskra/Dijskra/avi1.txt', 'w');
fprintf(fid, '%d %d \n ', x_size, y_size);
fprintf(fid, '%d %d \n ', xstart, ystart);
fprintf(fid, '%d %d \n ', xend, yend);
fprintf(fid, '%d %d \n ', theta_range(1), theta_range(2));
fprintf(fid, '%d %d \n ', varphi_range(1), varphi_range(2));

for ix = 1 : x_size
    for iy = 1 : y_size
        fprintf(fid, '%d ', avi(ix, iy));
    end
    fprintf(fid, '\n');
end
fclose(fid);
