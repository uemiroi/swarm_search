public class Swarm extends Creature {

  private float dist;
  
  //近傍半径の大きさ
  float NHO1 = 50.0;  // 衝突回避
  float NHO2 = 140.0; // 平均化
  float NHO3 = 200.0; // 誘引

  // 進行方向変更時の重み
  float param1 = 0.1; 
  float param2 = 0.1;
  float param3 = 0.1;

  float nx, ny, nd, nt; 

  public Swarm() {}

  float sign(float A) { //符号を返す（1.0 : -1.0）
    if (A==0) return 0;
    else return A/abs(A);
  }

  private void search(float d) { //半径dの近傍内に存在する個体
    int count = 0;
    for (int q=0; q<N; q++) {
      this.dist = dist(x, y, creature[q].x, creature[q].y);
      if (this.dist <= d && i!= q ) {
        count++;
        nx += creature[q].x;
        ny += creature[q].y;
        nt += creature[q].theta - creature[i].theta;
      }
    }
    if (nx != 0 || ny != 0) {
      nx = (nx / count) - creature[i].x;
      ny = (ny / count) - creature[i].y;
      nt = nt / count;
    }
  }

  private void searchob(float d) { //半径dの近傍内に存在する個体を検出
    int count = 0;
    for (int q=(int)-d; q<=d; q++) {
      for (int j=(int)-d; j<=d; j++) {
        if ( get(x+q, y+j) == color(0) && q != 0 && j != 0 ) { 
          this.dist = dist(x, y, x+q, y+j);
          if ( this.dist <= d ) {
            count++;
            nx += sign(q) * (d - abs(q));
            ny += sign(j) * (d - abs(j));
            nd += dist;
          }
        }
      }
    }
    if (nx != 0 || ny != 0) {
      nx = (nx / count);
      ny = (ny / count);
    }
  }

  private void avoidance() { //衝突回避
    float tr, r;
    searchob(NHO1);
    if (nx != 0 || ny != 0) {
      tr = atan2(-ny, -nx);
      r = (tr - theta) % (2*PI);
      if (r > PI) r = -2 * PI + r;
      if (r < -PI) r = 2 * PI + r;
      theta += r * param1;
    }
  }

  private void averaging() { //平均化
    nt = 0;
    search(NHO2);
    if (nd != 0 || nt != 0) {
      theta += nt * param2;
    }
  }

  private void attraction() { //誘引
    float tr, r;
    search(NHO3);
    if (nx != 0 || ny != 0) {
      tr = atan2(ny, nx);
      r = (tr - theta) % (2*PI);
      if (r > PI) r = -2 * PI + r;
      if (r < -PI) r = 2 * PI + r;
      theta += r * param3;
    }
  }

  public void interaction() {
    nx = 0;
    ny = 0;
    nd = 0; 
    nt = 0;
    avoidance();
    if (nx == 0 && ny == 0) averaging();
    if (nx == 0 && ny == 0) attraction();
  }
}
