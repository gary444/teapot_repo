public class Cup {
  
 private int x_pos;
 private int y_pos;
 private boolean is_hit;
 
 public Cup (float _x_pos, float _y_pos){
  
   is_hit = false;
   x_pos = (int)_x_pos;
   y_pos = (int)_y_pos;
 }
 
 public boolean getHit(){
   return is_hit;
 }
 public void setHit(boolean hit){
   is_hit = hit;
 }
 
 public int getX(){
   return x_pos;
 }
 public int getY(){
    return y_pos;
 }
 
 public void updateXPos(int speed){
   x_pos += speed;
}


}
