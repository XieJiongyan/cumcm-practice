x_size = 100;
y_size = 100;
avi = zeros(x_size, y_size);
theta_range = [68.48922302969956, 77.03805174668921];
varphi_range = [32.29551780818801, 61.38811031350902];
start_place = [58 + 48 / 60, 76 + 14/60];
end_place = [34, 69.5];
x2varphi = @(x) varphi_range(1) + (x - 1) / (x_size - 1)...
    * (varphi_range(2) - varphi_range(1));
y2theta = @(y) theta_range(1) + (y - 1) / (y_size - 1)...
    * (theta_range(2) - theta_range(1));
costline = load('input/costline.txt');

xy2ecs = @(x, y) [x2varphi(x), y2theta(y)];
varphi2x = @(varphi) round((varphi - varphi_range(1) )/ ...
    (varphi_range(2) - varphi_range(1)) *  (x_size - 1)) + 1;
theta2y = @(theta) round((theta - theta_range(1) ) / ...
    (theta_range(2) - theta_range(1)) * (y_size - 1)) + 1;
ecs2xy = @(varphi, theta) [varphi2x(varphi),...
    theta2y(theta)];
[m,n]=size(costline);

lasty=1;
thisy=1;
lastx=1;
thisx=1;
 
figure;
contourf(avi');
colorbar
fid = fopen('totalsolve/totalsolve/avi9.txt', 'w');
fprintf(fid, '%d %d \n ', x_size, y_size);
xstart = varphi2x(start_place(1));
ystart = theta2y(start_place(2));
xend = varphi2x(end_place(1));
yend = theta2y(end_place(2));
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

save model1.mat x_size avi y_size theta_range ...
    varphi_range start_place end_place x2varphi ...
    y2theta varphi2x theta2y