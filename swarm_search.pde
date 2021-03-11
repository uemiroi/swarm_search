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
   
