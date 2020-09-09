function [imgx, imgy] = xy2img(x, y)
load model1.mat x2varphi y2theta
load model1_2.mat ecs2img

varphi = x2varphi(x);
theta = y2theta(y);
imgpl = ecs2img(varphi, theta);
imgx = imgpl(1);
imgy = imgpl(2);
end