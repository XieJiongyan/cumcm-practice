#include <iostream>
#include <vector>
#include <queue>
#include <fstream>
#include <string>
#include <cmath>
#include <iomanip>
#include <array>
using namespace::std;

struct node {
  double dis;
  int beforex, beforey;
  bool avi, vis;
  node() : dis(100000000.0), beforex(0), beforey(0), avi(true), vis(false) {}
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
array< array<double, 1000>, 1000> Hs;
array< array<node, 1001> ,1001> nodes;
int x_size, y_size;
constexpr double R = 6357.0 / 1.852;
double varphi_range[2];
double theta_range[2];
double rho_0;

double x2varphi(int x);
double y2theta(int y);
void xy2img(int x, int y, int& imgx, int& imgy);
inline double h2speed(double h);
void read_ice();  //读取海冰厚度数据
void read_isle();//读取海岸线数据
constexpr double pi{ 3.1415926 };
bool dijskra();//
void path();//输出路径

int is_another_avi{ true };
int day(93); //0601 is 1, 0630 is 30
int origin_day(92);
int voyage(0); //第几段航程
vector<double> invtime(13, 0);
ofstream fout("voyage.txt");
ofstream tiout("time.txt");

signed main() {
  read_ice();
  origin_day = day;
  //int a, b;
  //xy2img(1, 1, a, b);
  //xy2img(1, 2, a, b);
  while (true) {
    while (!pq.empty())
      pq.pop();
    if (is_another_avi) {
      path();
      ++voyage;
      if (voyage > 12)
        break;
      cout << "is_another_avi is true, now the voyage is:"<< voyage << "\n" << endl;
      //string sin;
      //cin >> sin;
      read_isle();
      for (auto ix(1); ix <= x_size; ix++) {
        for (auto iy(1); iy <= y_size; iy++) {
          auto& t_node(nodes[ix][iy]);
          t_node.dis = 1e9, t_node.beforex = 0, t_node.beforey = 0, t_node.vis = false;
        }
      }
      nodes[xstart][ystart].dis = invtime[voyage - 1];
      pq.push(xnode(0, xstart, ystart, 0, 0));
    }
    else {
      int pq_size(0);
      day++;
      cout << "\nis_another_avi is false\n" << endl;
      vector<int> dates{ 30, 31, 31, 30 };
      read_ice();
      auto day_ = day - origin_day;
      for (auto ix(1); ix <= x_size; ix++) {
        for (auto iy(1); iy <= y_size; iy++) {
          auto& t_node(nodes[ix][iy]);
          if (nodes[ix][iy].dis > (day_ - 1) * 24 && nodes[ix][iy].dis < (day_ ) * 24) {
            nodes[ix][iy].dis = day_ * 24 + 0.03;
            nodes[ix][iy].vis = false;
            pq.push(xnode(t_node.dis, ix, iy, t_node.beforex, t_node.beforey));
            pq_size++;
          }
        }
      }
      cout << "end change priority_queue" << endl;
      cout << "priority queue size: " << pq_size << endl;
    }
    is_another_avi = dijskra();
  }
  return 0;
}

inline double x2varphi(int x) {//返回弧度
  return (varphi_range[0] + (double(x) - 1.0) / (x_size - 1) * (varphi_range[1] - varphi_range[0])) * pi / 180.0;
}
inline double y2theta(int y) {
  //cout << theta_range[0] << ' ' << theta_range[1] - theta_range[0] << endl;
  return pi / 180.0 * (theta_range[0] + (double(y) - 1.0) \
                       / (y_size - 1) * (theta_range[1] - theta_range[0]));
}
inline double theta2rho(double theta) {
  return rho_0 / 30 * (90 - theta / pi * 180);
}
inline double varphi2vartheta(double varphi) {
  return (varphi);
}
inline void xy2img(int x, int y, int& imgx, int& imgy) {
  double varphi{ x2varphi(x) }, theta{ y2theta(y) };
  double dvarphi{ x2varphi(x) / pi * 180 }, dtheta(theta / pi * 180);
  imgy = int(round(x_mid_img + theta2rho(theta) * sin(varphi2vartheta(varphi))));
  imgx = int(round(y_mid_img - theta2rho(theta) * cos(varphi2vartheta(varphi))));
  //cout << y_mid_img << ' ' << theta2rho(theta) << ' ' << cos(varphi2vartheta(varphi)) << endl;
  //cout << y << ' ' << theta << ' ' << theta / pi * 180 << endl;
  //cout << varphi << endl;
  //cout << "imgy is :" << imgy << endl;
}
inline double h2speed(double h) {
  if (h == -1)
    h = 0;
  return -0.000245902709762 * h * h - 0.044686255305256 * h + 10.975220372184134;
}
void read_ice() {  //读取海冰厚度数据
  vector<int> dates{ 30, 31, 31, 30 };
  int month(6);
  int this_day(day);
  for (int i(0); i < 4; month ++, i++) {
    if (this_day <= dates[i])
      break;
    else
      this_day -= dates[i];
  }
  string str_day = this_day < 10 ? '0' + to_string(this_day) : to_string(this_day);
  string ice_name("input/20200" + to_string(month) + str_day + ".txt");

  cout << "read ice name: " << ice_name << endl;
  ifstream fin(ice_name);
  fin >> m >> n;
  fin >> x_mid_img >> y_mid_img;
  x_mid_img = 176;
  y_mid_img = 154;
  fin >> rho_0;
  rho_0 = rho_0 * 0.9;
  for (auto im(1); im <= m; im++)
    for (auto in(1); in <= n; in++) {
      fin >> Hs[im][in];
    }
  fin.close();
}
void read_isle() {//读取海岸线数据
  string avi_name("avi" + to_string(voyage) + ".txt");
  cout << "avi_name is:" << avi_name << endl;
  ifstream avin(avi_name);
  avin >> x_size >> y_size;
  avin >> xstart >> ystart;
  avin >> xend >> yend;
  avin >> theta_range[0] >> theta_range[1] >> varphi_range[0] >> varphi_range[1];
  cout << "range: " << theta_range[0] << ' ' << theta_range[1] << endl;
  int in;
  for (auto ix(1); ix <= x_size; ix++)
    for (auto iy(1); iy <= y_size; iy++) {
      avin >> in;
      if (in == 0)
        nodes[ix][iy].avi = true;
    }

}

bool dijskra(void) {
  cout << "start dijskra" << endl;
  int imgx, imgy;
  int t_x, t_y;
  int nodes_found(0), times_anotherday(0), nodes_attempt(0), pq_pop_times(0), \
    times_height(0), times_finding(0), times_norestrict(0);
  while (!pq.empty()) {
    //读取最近的点
    xnode t_xnode{ pq.top() };
    pq.pop();
    pq_pop_times++;
    t_x = t_xnode.poix, t_y = t_xnode.poiy;
    if (nodes[t_x][t_y].vis)
      continue;
    auto& t_node(nodes[t_x][t_y]);
    //设置最近的点
    t_node.vis = true;
    nodes_found++;
    nodes[t_x][t_y].beforex = t_xnode.lax;
    nodes[t_x][t_y].beforey = t_xnode.lay;
    //cout << t_node.dis << endl;
    //判断是否是终点
    if (xend == t_x && yend == t_y) {
      invtime[voyage] = t_node.dis;
      cout << "end dijskra, return true" << endl;
      return true;
    }
    //搜索该点附近的点
    for (int ix = -1; ix <= 1; ix++)
      for (int iy = -1; iy <= 1; iy++) {
        //判断特殊情况
        if (ix == 0 && iy == 0)
          continue;
        if (t_x + ix > x_size || t_x + ix < 1 || t_y + iy > y_size || t_y + iy < 1)
          continue;
        if (!nodes[t_x + ix][t_y + iy].avi)
          continue;
        times_finding++;
        //计算距离
        double dist{ R * acos(sin(y2theta(t_y)) * sin(y2theta(t_y + iy)) + \
                             cos(y2theta(t_y)) * cos(y2theta(t_y + iy)) * \
                             cos(x2varphi(t_x) - x2varphi(t_x + ix))) };
        //计算到达该点所需的时间
        double speed{ 11.0 };
        xy2img(t_x + ix, t_y + iy, imgx, imgy);
        if (imgx > 0 && imgy > 0 && Hs[imgx][imgy] > 1.8) {
          times_height++;
          speed = 4.1 -Hs[imgx][imgy];
          speed = speed * speed;
        }
        else if (imgy <= 0 || imgx <= 0)
          speed = 11;
        else
          speed = h2speed(Hs[imgx][imgy] - 0.7);
        //cout << speed << ' ' << endl;
        if (speed < 0) {
          cout << "Wrong speed without reason!" << endl;
          string s;
          cin >> s;
          continue;
        }
        //cout << "speed :" << speed << endl;
        double vartime{ dist / speed };
        //如果只能下一天到达下一个点，那么不会加到堆中
        if (t_node.dis + dist > (day - origin_day + 1) * 24) {
          times_anotherday++;
          continue;
        }
        times_norestrict++;
        if (nodes[t_x + ix][t_y + iy].dis > t_node.dis + vartime + 1e-6) {
          nodes[t_x + ix][t_y + iy].dis = t_node.dis + vartime;
          pq.push(xnode(t_node.dis + dist, t_x + ix, t_y + iy, t_x, t_y));
          nodes_attempt++;
        }

      }
  }
  cout << "end dijskra, return false" << endl;
  cout << "found nodes: " << nodes_found << endl;
  cout << "priority queue pop times : " << pq_pop_times << endl;
  cout << "finding times: " << times_finding << endl;
  cout << "heights restrict times: " << times_height << endl;
  cout << "another day times: " << times_anotherday << endl;
  cout << "no restrict times: " << times_norestrict << endl;
  cout << "attempt nodes: " << nodes_attempt << endl;
  return false;
}
void path() {//输出路径
  if (xend == 0 && yend == 0)
    return;
  cout << nodes[xend][yend].dis << endl;
  tiout <<nodes[xend][yend].dis << endl;

  for (int printx{ xend }, printy{ yend }; printx != xstart || printy != ystart;) {
    cout << "(x, y) = " << printx << ' ' << printy << ' ' << nodes[printx][printy].dis << endl;
    int imgx(0), imgy(0);
    xy2img(printx, printy, imgx, imgy);
    fout << x2varphi(printx)/pi * 180 << ' ' << y2theta(printy)/pi * 180 << endl;
    auto lax(nodes[printx][printy].beforex);
    auto lay(nodes[printx][printy].beforey);
    printx = lax, printy = lay;
    if (printx == 0 && printy == 0)
      break;
  }
}