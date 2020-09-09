close all
thicknesss = [0 50 80 105];
speeds = [11 8 6 3.5];
[p, plyv] = polyfit(thicknesss, speeds, 2);
m_thicks = 0 : 170;
predict_speeds = polyval(p, m_thicks);
polyval(p, 110)
plot(m_thicks, predict_speeds);
hold on
plot(thicknesss, speeds, 'ro')