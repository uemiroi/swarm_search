public class Creature{
  int x, y;  //現在の座標
  int tx, ty;  //目標座標
  float theta;  //目標座標への方角
  float dist;  //目標座標への距離
  float d = 5; //1サイクルで進む距離
  
  public Creature(){  //個体の初期値を設定（コンストラクタ）
    x = (int)width/2 + (int)random(-50,50);
    y = (int)height/2 + (int)random(-50,50);
    tx = x;
    ty = y;
    theta = 0.0;
    dist = 0.0;
  }
  
  private void getDist(){  
     theta = (theta + random(-PI/2, PI/2)) % (2*PI);
     dist= random(5, width/5);
    }
  
  private void move(){
    x = x +  (int) ( d *  cos(theta));
    y = y +  (int) ( d *  sin(theta));
    dist = dist - d;
  }
  
  public void action(){
    //目的座標のaff内に到着した場合は座標を更新する
    tx = x;
    ty = y;
    if(dist <= 0) getDist();
   
    //次の目標座標が探索空間内にあるか
    while(tx >= width -10 || ty >= height -10 || tx <= 10 || ty <= 10){
      getDist();
       tx = x +  (int) ( d *  cos(theta));
       ty = y +  (int) ( d *  sin(theta));
    }
    move();
  }
  
  public void show(color c, int m){  //生物を表示
    fill(c);
    stroke(c);
    ellipse(x,y,m,m);
  }
}
