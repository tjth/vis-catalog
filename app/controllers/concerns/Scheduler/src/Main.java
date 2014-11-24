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

//    Scheduler1xN sc1xn = new Scheduler1xN(15);
//    
//    sc1xn.schedule(Arrays.asList(ps[1][1][3], ps[2][2][5], ps[4][1][10], ps[3][1][7], ps[5][2][10]));
//    System.out.println(sc1xn);
//    sc1xn.reset();
//    
//    sc1xn.schedule(Arrays.asList(ps[1][3][3]));
//    System.out.println(sc1xn);
//    sc1xn.reset();
//    
//    sc1xn.schedule(new ArrayList<Programme>());
//    System.out.println(sc1xn);
//    sc1xn.reset();
    
    Scheduler2x2 sc2x2 = new Scheduler2x2(6);
    
    sc2x2.schedule(new ArrayList<Programme>());
    System.out.println(sc2x2);
    sc2x2.reset();
  }

}
