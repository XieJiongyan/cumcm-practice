x_size = 100;
y_size = 100;
avi = zeros(x_size, y_size);
theta_range = [66.10329253849469, 67.09918891328769];
varphi_range = [-171.9959574849226, -169.2677190732407];
start_place = [-(169.5),66 + 10 / 60];
end_place = [-171.5, 67];
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
 
for i=2:m
     varphi=costline(i,1);
     theta=costline(i,2);
     
     thisx=varphi2x(varphi);
     thisy=theta2y(theta);
     
     if(thisx==lastx || (i~=1 && thisy==lasty)) 
         continue
     end
     
     for j=1:thisx
         for k=lasty + 1:thisy
             avi(j,k)=1;
         end
     end
     lasty=thisy;
     lastx=thisx;
end
figure;
contourf(avi');
colorbar
fid = fopen('Dijskra/Dijskra/avi.txt', 'w');
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

save model1.mat x_size avi y_size theta_range ...
    varphi_range start_place end_place x2varphi ...
    y2theta varphi2x theta2y