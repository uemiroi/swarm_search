# swarm_search
Boidモデルに基づく群れシミュレーションプログラム
このシミュレーションはBoidモデルを参考に，集団を群れとして行動させます．ソースコードは大きく分けて以下の3つから構成されています．

- [main.pde](#mainpde)
- [creature.pde（Creatureクラス）](#creaturクラス)
- [swarm.pde（Swarmクラス）](#swarmクラス)

この記事では，[processingの基本構文](http://dev.eyln.com/books/magical/Processing%E3%83%81%E3%83%BC%E3%83%88%E3%82%B7%E3%83%BC%E3%83%88.pdf)は抑えていることを前提に説明を行います．

## main.pde

シミュレーションの核となる部分です．**シミュレーション全体の初期設定**と**フレームごとに実行する処理**を記述しています．

```java
//main.ped
int N = 3;
float MIN ;
float MAX ;
int i;

Swarm[] creature;

void reset(){
  creature = new Swarm[N];
  for(int j=0; j<N; j++){
    creature[j] = new Swarm();
    creature[j].show(0,5);
  }
  background(255);
  /*　探索空間の周囲を黒線で囲む　*/
  stroke(0);
  noFill();
  rect(0,0,width-1,height-1);
}

void setup(){  
  frameRate(120);
  size(600, 600);
  reset();
}

void draw(){
   for(i=0; i<N; i++){
    creature[i].show(255,7);
    creature[i].action();
    creature[i].interaction();
    creature[i].show(0,5); 
   }
}
```

上記がソースコード全体です．順番に説明していきます．
### パラメータの設定

```java
int N = 3; //エージェントの数
float MIN; //直線で移動する最大距離導出に使用　
float MAX; //直線で移動する最小距離導出に使用
int i; //各エージェントに与えられる個体番号
```
各パラメータの初期値をを設定しています．概要はコメントの通りです．
<br>

```java
Swarm[] creature;
```
Creatureクラスを継承したSwarmクラスからオブジェクトを生成するために配列のフィールドを宣言します．
### reset()

```java

void reset(){
  creature = new Swarm[N];
  for(int j=0; j<N; j++){
    creature[j] = new Swarm();
    creature[j].show(0,5);
  }
  /*　探索空間の周囲を黒線で囲む　*/
  background(255);
  stroke(0);
  noFill();
  rect(0,0,width-1,height-1);
}
```
エージェントをインスタンス化します．[後述](#show)で説明しますが，`show()`はエージェントを描画するメソッドです．
今回は**黒色**を回避するようにシミュレーションを実装するため，壁外にエージェントが移動しないように空間の周囲を黒線で囲っています．
### setup()
```java
void setup(){   
  frameRate(120); //1秒に実行するフレーム数
  size(600, 600);
  reset();
}
```
シミュレーション実行時に一度だけ実行する処理を記述します．今回はデータ計測を自動化するためにreset()を別で用意しましたが，まとめても問題ありません．
### draw()
```java
void draw(){
   for(i=0; i<N; i++){
    creature[i].show(255,7);
    creature[i].action();
    creature[i].interaction();
    creature[i].show(0,5); 
   }
}
```
1フレームで実行する処理を記述．エージェント毎に以下の処理を行う．

1. 前フレームで描画したエージェントを白で上塗りして消す
2. 次の進行位置をランダムで導出
3. Boidモデルに基づいた相互作用により2.で導出した進行位置を更新
4. エージェントを描画

これをフレーム毎に繰り返すことでエージェントが少しずつ移動し，群れのアニメーションとなる．

##  Creaturクラス
エージェントの初期値の設定や，描画，移動方向＆距離の決定など，エージェントに関する基本的な機能を記述しています．

```java
//Creaturクラス
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
```
このクラスによってエージェントを描画することができますが，群れとしてではなく完全に独立して行動を行います．
上記がクラス全体のコードです．前項と同様に順に説明します．

### パラメータの設定
```java
int x, y;  //現在の座標
int tx, ty;  //目標座標
float theta;  //目標座標への方角
float dist;  //目標座標への距離
float d = 5; //1サイクルで進む距離
```
各パラメータの概要はコメントの通りです．`d=5`は小さくするとエージェントの移動方向が限定されてしまいます．詳しくは後述で説明します．

### コンストラクタ
```java
public Creature(){  //個体の初期値を設定（コンストラクタ）
    x = (int)width/2 + (int)random(-50,50);
    y = (int)height/2 + (int)random(-50,50);
    tx = x;
    ty = y;
    theta = 0.0;
    dist = 0.0;
  }
```
エージェントが持つパラメータの初期値を設定します．初期位置は空間中央から100×100の範囲としています．このシミュレーションでは進行角度theta，進行距離distから次に目標とする座標tx，tyを求めます．ひとまずこの段階ではx，yを代入しておきます．

### getDist()
```java
 private void getDist(){  
     theta = (theta + random(-PI/2, PI/2)) % (2*PI);
     dist= random(5, width/5);
    }
```

次の目標座標を導出するのに必要な**進行角度theta**と**進行距離dist**を求めます．thetaは現在の角度に-π/2からπ/2の範囲でランダムに導出した値を加算します．この時，thetaが2πを超えないように`%2π`としています．

### move()
```java
private void move(){
    x = x +  (int) ( d *  cos(theta));
    y = y +  (int) ( d *  sin(theta));
    dist = dist - d;
  }
```
`getDist()`で求めた値に従ってエージェント進行方向に向かって`d`ずつ加算します．
（ d を小さくするほど進行方向は限定されてしまいます）

### action()
```javascript
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
```
エージェントが目標座標tx，tyに到達している場合`getDist()`により新たな目標座標を導出し，到達していない場合`move()`によりエージェントを進行させます．また，目標座標が空間外にある場合は，空間内に導出されるまで繰り返し`getDist()`を行っています．

### show()
```java
public void show(color c, int m){  
    fill(c);
    stroke(c);
    ellipse(x,y,m,m);
  }
```
エージェントを表示するメソッドです．引数は色を表現する属性とエージェントの大きさから構成されています．

Creaturクラスの説明は以上です．いくつかメソッドがありましたが，基本的に外部使用するのは，エージェントを進行させる`action()`と，実際に描画を行う`show()`ののみです．この2つのメソッドによって，各々のエージェントが移動しているようなアニメーションを作成することができます．

## Swarmクラス
ここでは各エージェントに下記の3つ相互作用を与えて進行方向を調節します．

1. 衝突回避
2. 平均化
3. 誘引

このシミュレーションを作成した中で最も難航した部分でもあります．ところどころ力業で実装しているため改善する必要があると思われます．

```java
//Swarmクラス
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
```

コード全体です．例にもれず順に説明します．

### パラメータの設定
```java
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
      
       /* 省略 */
}
```
**Swarmクラス**は**Creatureクラス**を継承します．今回はエージェントの基本的な機能（Creaturクラス）を実装してから，群れとして行動する機能（Swarmクラス）を加えたため別れていますが，一つにしても問題ありません．

### コンストラクタ
```java
  public Swarm() {}
```
特に内容はありませんが決まりなので記述しておきます．
### sign()
```java
float sign(float A) { //符号を返す（1.0 : -1.0）
    if (A==0) return 0;
    else return A/abs(A);
  }
```
数値を渡すとその符号を返します．

-（負の数）の場合　→　返り値は`-1.0`
+（正の数）の場合　→　返り値は`1.0`

### search()
```java
private void search(float d) { //半径dの近傍内に存在する個体を検出
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
    // 複数存在した場合平均を取る
    if (nx != 0 || ny != 0) {
      nx = (nx / count) - creature[i].x;
      ny = (ny / count) - creature[i].y;
      nt = nt / count;
    }
  }
```
引数として渡した近傍半径内に存在する他個体を検出し，座標nx，xy，他個体との距離nd，他個体の進行方向ntを返します．4行目で中心個体と他個体との距離を算出し，5行目のif文で，指定した近傍半径内に存在する中心個体（個体番号i）以外の他個体を選出しています．これを個体の数だけ繰り返し，複数の個体が存在する場合にはそれらの平均を取ります．
このメソッドは「平均化」と「誘引」を行う際に使用します．

### searchob()
```java
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
```
`search()`と基本的に同様の機能を持っていますが，他個体のみではなく，壁などの障害物も検出します．検出方法も異なり，今回は近傍内の空間を順番に比較して黒色を検出した際にその情報を合算していきます．このメソッドは「衝突回避」を行う際に使用するため，障害物が近いほど個体に与える影響を強くする必要がありました．そのため，9，10行目のような処理を行っています．（かなり力業ですが．．．）ちなみに`abs()`は絶対値を返すメソッドです．

### avoidance()
```java
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
```
`searchob()`で算出した障害物の座標を基に，エージェントの進行方向を衝突を回避する方向へ更新します．`param1`の値を大きくするとそれと比例してエージェントに与える相互作用の影響も大きくなります．

### averaging()
```java
private void averaging() { //平均化
    nt = 0;
    search(NHO2);
    if (nd != 0 || nt != 0) {
      theta += nt * param2;
    }
  }
```
`search()`で算出した他個体の座標を基に，エージェントの進行方向を周囲のエージェントと合わせる向きへ更新します．

### attraction()
```java
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
```
`search()`で算出した他個体の座標を基に，エージェントの進行方向を他個体に追従する向きへ更新します．

### interraction()
```java
public void interaction() {
    nx = 0;
    ny = 0;
    nd = 0; 
    nt = 0;
    avoidance();
    if (nx == 0 && ny == 0) averaging();
    if (nx == 0 && ny == 0) attraction();
  }
```
群れの動きに相互作用の影響を与えたいときに呼び出すメソッドです．相互作用を与える優先順位としては「衝突回避」→「平均化」→「誘引」です．優先順位が高い順に実行し，近傍半径内に障害物が存在し速度を更新した場合はそれ以下のメソッドは実行しません．

Swarmクラスの説明は以上です．一見複雑に思えるかもしれませんが，一つ一つで見るとそこまで難しいことはしていません．ただ，このクラスに関してはかなり強引に実装しているためところどころ穴はありますが．．．

## まとめ

以上より群れのシミュレーションプログラムを実装できます．しかし，何度も繰り返していますが，**3つの相互作用を与える**という点でコードが複雑化してしまい余剰な処理が生まれてしまっているように思います．時間が許すならもう一度一から設計しなおすのがベターかもしれません．
