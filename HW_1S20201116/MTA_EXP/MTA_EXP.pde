
int start_x=200;
float start_time=millis();
int first_click=0;
int play_flag=1; int success_flag=0;
color ac_color = #320000;
/*
d=s*t 
if)speed = 1000 > t_zone+start_x, t_cue
speed = 500 > t_zone/2 + start_x+
*/
class Ball {
  PVector Pos = new PVector(0,200);
  PVector Direction = new PVector(0,0);
  color Colour = color(255);
  int speed = 500; //speed1000->1000=>1000ms(0.1)
  int size = 30;

  Ball() {
    Direction = new PVector(1000,0);
    Colour = color(255);
  }
  void draw() {
    render();
    update();
  }
  
  void render() {
    fill(Colour);
    ellipse(Pos.x, Pos.y, size, size);
  }
  void update(){
   Colour = color(255);
   fill(Colour);
    Pos.x+=Direction.normalize().x*1/frameRate*speed;
    Pos.y+=Direction.normalize().y*1/frameRate*speed;
  }

  void resetBall(){
    success_flag=0;
    first_click=0;
    Pos.x=start_x;
    Pos.y=200;
    start_time=millis();
    Colour=color(255);
  }

}

//////////////////////////////////////////////////////////////////////////////////
Ball ball = new Ball();
/*set conditions
  Condition#-[tcue, tzone, p]
  */
  
int[][] Condition = {{0,80,1000},
                     {0,150,1000},
                     {0,80,1500},
                     {0,150,1500},
                     {100,80,1000},
                     {100,150,1000},
                     {100,80,1500},
                     {100,150,1500},
                   };
//order of condition
IntList order;             

///////////////////////////////////////////////////////////////////////////////////
Table table;
int st = millis();
void setup() {
  frameRate(60);
  size(900, 400);
  
  //get condition in randome order
  order = new IntList();
  for(int i=0;i<8;i++) order.append(i);
  order.shuffle();

  //
  table = new Table();
  make_table(table);
  //ect

 
}
//for ac zone color
int green_flag=0; float time_color = millis();
color c1= #00FF00;
color c2= #320000;
//
int timer=millis();
int t_cue, t_zone, p;
int N=35; //number of total trials 
int count=N; // #of done trials

void draw() {
   background(#000000);

   info();
   acquisition_zone();
  
   //////
   ball.draw();
   //new ball every p
   if(millis()-timer>p && millis()>1000 &&  play_flag==1){ //added millis()>2000 so have 2 sec to prepare for start
       ball.resetBall();
       ball.draw();
       count--;
       timer=millis();
   }
   

//blink when success
  if(green_flag==1 && millis()-time_color<200) {

    if(ac_color ==c1) ac_color=c2;
    else ac_color = c1;
  }
  else {
    green_flag=0;
    ac_color = c2;
  }
   
 //rest between conditions
    if(count==0) {
     ChangeCondition(); //change condition after 35 tries
     play_flag=0;
   }

  if(mousePressed){
      play_flag=1;
   }
   if(play_flag ==0){
     fill(255);
     rect(310,150,250,110);
     textSize(20);
     fill(0);
     text(" CLICK TO START \nNEXT CONDITION",350,200);
     ball.Colour=color(0);
   }
    if(millis()<2000) { //load time
     fill(0);
     rect(0,0,900,400);
   }

}
///////////////////////////////////////////////////////////////////////////////////
//change condition when each condition is done
int num;
void ChangeCondition(){
  if(order.size() !=0){ 
    num = order.pop();
    t_cue=Condition[num][0];
    t_zone=Condition[num][1];
    p=Condition[num][2];
    count=N; success=0;
  }
  else { //all conditions done
    println("DONE");
    exit();
  }
}

int curr_time;
int success=0; //to count success
int k=0;
void keyPressed() { //for first half tries
  if(num<4){
    k=0;
  if(first_click==0){
     curr_time=millis();
    //if(ball.Pos.x > t_cue/2+start_x && ball.Pos.x<t_cue/2+start_x+t_zone/2)success++; 
     if((curr_time-start_time)>t_cue &&  (curr_time-start_time)<t_cue+t_zone) {
       success++;
       green_flag=1;
       time_color = millis();
       success_flag=1;
     }
     save_table();
  }
  first_click=1;
  }
}
void keyReleased() {//for second half tries
  if(num>=4){
    k=1;
  if(first_click==0){
     curr_time=millis();
    //if(ball.Pos.x > t_cue/2+start_x && ball.Pos.x<t_cue/2+start_x+t_zone/2)success++; 
     if((curr_time-start_time)>=t_cue &&  (curr_time-start_time)<=t_cue+t_zone) {
       success++;
       green_flag=1;
       time_color = millis();
       success_flag=1;
     }
     save_table();
  }
  first_click=1;
  }
}
void acquisition_zone(){
 
  fill(ac_color); //dark red
  rect(t_cue/2+start_x, 0, t_zone/2, 400);
 
}

///////////////////////////////////////////////////////////////////////////////////
void info(){
  //text that indicates the number of remaining trials, conditions, etc
  fill(#FFFFFF);
  rect(10,10,200,125);
  fill(#000000);
  textSize(15);
  text("\tInfo \nremaining trials: " + count, 20,25);
  text("number of success: " + success, 20, 70);
  text("t_cue: " + t_cue, 20, 90);
  text("t_zone: " + t_zone, 20, 110);
  text("p: " + p, 20, 130);
}
///////////////////////////////////////////////////////////////////////////////////

void make_table(Table table){
  //make data table
  table.addColumn("timestamp");
  table.addColumn("cond");
  table.addColumn("trial");
  table.addColumn("success");
  table.addColumn("t_cue",Table.INT);
  table.addColumn("t_zone", Table.INT);
  table.addColumn("p", Table.INT);
  table.addColumn("key", Table.INT);
}

void save_table(){
  TableRow row = table.addRow();
  row.setFloat("timestamp", (curr_time-start_time)-t_cue);
  row.setInt("cond", num);
  row.setInt("trial", count);
  row.setInt("success", success_flag);
  row.setInt("t_cue", t_cue);
  row.setInt("t_zone", t_zone);
  row.setInt("p", p);
  row.setInt("key", k);
  saveTable(table, "./S2020111dd6.csv");
}


///////////////////////////////////////////////////////////////////////////////////
