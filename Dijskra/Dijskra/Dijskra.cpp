#include <iostream>
#include <vector>
#include <queue>
#include <fstream>
#include <string>
#include <cmath>
using namespace::std;

struct node {
  double dis;
  int beforex, beforey;
  bool avi, vis;
  int poi;
};
struct xnode {
  double dis;
  int poix, poiy;
  int lax, lay;
  xnode(double fd, int fx, int fy, int lx, int ly) : \
    dis(fd), poix(fx), poiy(fy), lax(lx), lay(ly) {}
  bool operator<(const xnode& n) const {
    return dis > n.dis;
  };
};

priority_queue<xnode> pq;

int n, m;
int xstart, ystart;
int xend, yend;
int x_mid_img, y_mid_img;
double Hs[1000][1000]{ 0 };
node nodes[1000][1000]{ 0 };
int x_size, y_size;
constexpr double R = 6357.0 / 1.852;
double varphi_range[2];
double theta_range[2];
double rho_0;

double x2varphi(int x);
double y2theta(int y);
void xy2img(int x, int y, int& imgx, int& imgy);
inline double h2speed(double h);

signed main(){
  ifstream fin("20200701.txt");
  fin >> m >> n;
  fin >> x_mid_img >> y_mid_img;
  fin >> rho_0;
  for (auto im(1); im <= m ; im++) 
    for (auto in(1); in <= n; in++) {
      fin >> Hs[im][in];
    }
  fin.close();
  ifstream avin("avi1.txt");
  avin >> x_size >> y_size;
  avin >> xstart >> ystart;
  avin >> xend >> yend;
  avin >> theta_range[0] >> theta_range[1] >> varphi_range[0] >> varphi_range[1];
  int in;
  for (auto ix(1); ix <= x_size; ix++)
    for (auto iy(1); iy <= y_size; iy++) {
      avin >> in;
      if (in == 0)
        nodes[ix][iy].avi = true;
    }
  for (auto ix(1); ix <= x_size; ix++) {
    for (auto iy(1); iy <= y_size; iy++) {
      nodes[ix][iy].dis = 1e9;
    }
  }
  nodes[xstart][ystart].dis = 0.0;
  pq.push(xnode(0, xstart, ystart, 0, 0));
  int imgx, imgy;
  while (!pq.empty()) {
    xnode t_xnode{ pq.top() };
    pq.pop();
    int t_x{ t_xnode.poix }, t_y{ t_xnode.poiy };
    if (nodes[t_x][t_y].vis)
      continue;
    auto& t_node(nodes[t_x][t_y]);
    t_node.vis = true;
    nodes[t_x][t_y].beforex = t_xnode.lax;
    nodes[t_x][t_y].beforey = t_xnode.lay;
    for (int ix = -1; ix <= 1; ix++)
      for (int iy = -1; iy <= 1; iy++) {
        if (ix == 0 && iy == 0)
          continue;
        if (t_x + ix > x_size || t_x + ix < 1 || t_y + iy > y_size || t_y + iy < 1)
          continue;
        if (!nodes[t_x + ix][t_y + iy].avi)
          continue;
        double dist{ R * acos(sin(y2theta(t_y)) * sin(y2theta(t_y + iy)) + \
                             cos(y2theta(t_y)) * cos(y2theta(t_y + iy)) * \
                             cos(x2varphi(t_x) - x2varphi(t_x + ix))) };
        //cout << sin(y2theta(t_y)) * sin(y2theta(t_y + iy)) << endl;
        //cout << cos(y2theta(t_y)) * cos(y2theta(t_y + iy)) * \
        //  cos(x2varphi(t_y) - x2varphi(t_y + iy)) << endl;
        //cout << acos(sin(y2theta(t_y)) * sin(y2theta(t_y + iy)) + \
        //             cos(y2theta(t_y)) * cos(y2theta(t_y + iy)) * \
        //             cos(x2varphi(t_x) - x2varphi(t_y + iy))) << endl;
        //cout << dist << endl;
        xy2img(t_x + ix, t_y + iy, imgx, imgy);
        double speed{ h2speed(Hs[imgx][imgy]) };
        //cout << "speed :" << speed << endl;
        double vartime{ dist / speed };
        if (nodes[t_x + ix][t_y + iy].dis > t_node.dis + vartime) {
          nodes[t_x + ix][t_y + iy].dis = t_node.dis + vartime;
          pq.push(xnode(t_node.dis + dist, t_x + ix, t_y + iy, t_x, t_y));
          }

      }
  }
  cout << nodes[xend][yend].dis << endl;
  for (int printx{ xend }, printy{ yend }; printx != xstart || printy != ystart;) {
    cout << "(x, y) = " << printx << ' ' << printy << ' ' << nodes[printx][printy].dis << endl;
    auto lax(nodes[printx][printy].beforex);
    auto lay(nodes[printx][printy].beforey);
    printx = lax, printy = lay;
  }
  return 0;
}

constexpr double pi{ 3.1415926 };
inline double x2varphi(int x) {//返回弧度
  return (varphi_range[0] + (double(x) - 1.0) / (x_size - 1) * (varphi_range[1] - varphi_range[0])) * pi / 180.0;
}

inline double y2theta(int y) {
  return pi / 180.0 * (theta_range[0] + (double(y) - 1.0) \
                       / (y_size - 1) * (theta_range[1] - theta_range[0]));
}

inline double theta2rho(double theta) {
  return rho_0 / 30 * (90 - theta);
}
inline double varphi2vartheta(double varphi) {
  return pi / 180.0 * (varphi);
}
inline void xy2img(int x, int y, int& imgx, int& imgy) {
  double varphi{ x2varphi(x) }, theta{ y2theta(y) };
  imgx = int(round(x_mid_img + theta2rho(theta) * sin(varphi2vartheta(varphi))));
  imgy = int(round(y_mid_img - theta2rho(theta) * cos(varphi2vartheta(varphi))));
}

inline double h2speed(double h) {
  return -0.000245902709762 * h * h - 0.044686255305256 * h + 10.975220372184134;
}