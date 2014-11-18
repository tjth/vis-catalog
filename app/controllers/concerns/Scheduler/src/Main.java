import java.util.ArrayList;
import java.util.Arrays;

public class Main {

  public static void main(String[] args) {
    Visualisation v1 = new Visualisation(" V01 ", 1);
    Visualisation v2 = new Visualisation(" V02 ", 2);
    Visualisation v3 = new Visualisation(" V03 ", 3);
    Programme p1 = new Programme(v1, 2, 3);
    Programme p2 = new Programme(v2, 1, 6);
    Programme p3 = new Programme(v3, 1, 9);

    Scheduler sc = new Scheduler(8);
    sc.schedule(new ArrayList<Programme>());
    System.out.println(sc);
    sc.reset();
    sc.schedule(Arrays.asList(p1, p2, p3));
    System.out.println(sc);
    sc.reset();
  }

}
