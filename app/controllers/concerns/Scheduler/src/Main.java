import java.util.ArrayList;
import java.util.Arrays;

public class Main {

  public static void main(String[] args) {
    int maxM = 5, maxS = 4, maxP = 10;
    Visualisation[] vs = new Visualisation[maxM + 1];
    for (int m = 1; m <= maxM; m++) {
      vs[m] = new Visualisation(" V0" + m + " ", m);
    }
    Programme[][][] ps = new Programme[maxM + 1][maxS + 1][maxP + 1];
    for (int m = 1; m <= maxM; m++) {
      for (int s = 1; s <= maxS; s++) {
        for (int p = 1; p <= maxP; p++) {
          ps[m][s][p] = new Programme(vs[m], s, p);
        }
      }
    }

    Scheduler sc = new Scheduler(30);
    

//    sc.schedule(Arrays.asList(ps[1][1][3], ps[2][2][5], ps[4][1][10], ps[3][1][7], ps[5][1][10]));
//   System.out.println(sc);
//    sc.reset();

//    sc.schedule(Arrays.asList(ps[1][1][3], ps[2][2][5], ps[4][1][10], ps[3][1][7], ps[5][2][10]));
//    System.out.println(sc);
//    sc.reset();
    
    sc.schedule(Arrays.asList(ps[1][2][1], ps[2][1][1], ps[1][1][2]));
    System.out.println(sc);
    sc.reset();
    
//    sc.schedule(Arrays.asList(ps[1][2][1], ps[2][1][5], ps[1][1][10]));
//    System.out.println(sc);
//    sc.reset();
    
    sc.schedule(new ArrayList<Programme>());
    System.out.println(sc);
    sc.reset();
  }

}
