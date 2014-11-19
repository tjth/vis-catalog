import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.PriorityQueue;

public class Scheduler {

  private static final int SCREENS = 4;
  private int mins;
  private List<Session> sessions = new ArrayList<Session>();

  public Scheduler(int mins) {
    this.mins = mins;
    reset();
  }

  public void reset() {
    sessions.clear();
  }

  public void schedule(List<Programme> progs) {
    PriorityQueue<ProgTimer> pq = createQueue(progs);
    int[] nextFreeSlot = new int[SCREENS]; // tracks the next free slot for each screen
    for (int s = 0; s < SCREENS; s++) {
      nextFreeSlot[s] = 0;
    }
    List<ProgTimer> selectedPTs = new ArrayList<ProgTimer>(); // list of ProgTimers to requeue after scheduling
    List<Programme> selectedProgs = new ArrayList<Programme>(); // list of Programmes to schedule
    for (int m = 0; m < mins; m++) {
      for (int check = 0; check < SCREENS; check++) { // check for free slots at time m
        if (nextFreeSlot[check] <= m) { // free slot found
          int startSlot = check; // start of free slot
          int blockSize;
          for (blockSize = 1; check + blockSize < SCREENS; blockSize++) { // check for consecutive free slots at time m
            if (nextFreeSlot[check + blockSize] > m) { // end of free block
              break;
            }
          }
          check += blockSize; // move check to end of free block
          int filled = 0; // records number of filled slots in block
          while (!pq.isEmpty() && filled < blockSize) { // select programmes to fill block
            ProgTimer pt = pq.peek();
            if (pt.prog.getScreens() > blockSize - filled) { // selected programme is too big
              break;
            }
            pq.remove(); // remove selected programme from queue
            if (pt.prog.getDuration() <= 2 * (mins - m)) { // select programme if >= half can be played
              selectedProgs.add(pt.prog); // schedule programme
              filled += pt.prog.getScreens();
              selectedPTs.add(pt); // requeue programme
            } else {
              // programme cannot be selected to play at a later time anyway, don't bother requeueing
            }
          }
          int tryFill = 0;
          while (filled < blockSize && Programme.defProgs.length > 0) { // fill remainder of block with default programmes
            Programme defProg = Programme.defProgs[(int)(Math.random() * Programme.defProgs.length)];
            if (filled + defProg.getScreens() <= blockSize) { // selected programme can fit
              selectedProgs.add(defProg);
              filled += defProg.getScreens();
              tryFill = 0; // reset and pick another default programme
            } else if (++tryFill >= 3) { // stop if no default programme that can fit is found after a few tries
              break;
            }
          }
          Collections.sort(selectedProgs); // sort selected programmes in ascending duration order
          boolean ascend; // indicates if block should be filled from shortest to longest duration or vice versa
          if (startSlot == 0 && blockSize < SCREENS ||
              startSlot > 0 && startSlot + blockSize < SCREENS &&
              nextFreeSlot[startSlot - 1] > nextFreeSlot[startSlot + blockSize]) { // better to align left ie. longest to shortest
            ascend = false;
          } else if (startSlot + blockSize == SCREENS && blockSize < SCREENS ||
              startSlot > 0 && startSlot + blockSize < SCREENS &&
              nextFreeSlot[startSlot - 1] > nextFreeSlot[startSlot + blockSize]) { // better to align right ie. shortest to longest
            ascend = true;
          } else { // no alignment preference
            ascend = Math.random() < 0.5;
          }
          if (ascend) { // schedule selected programmes in ascending duration order
            startSlot += blockSize - filled; // starting position of 1st selected programme
            while (!selectedProgs.isEmpty()) {
              Programme prog = selectedProgs.remove(0);
              int endTime = Math.min(m + prog.getDuration(), mins); // in case programme exceeds allocated timeslot
              sessions.add(new Session(prog, startSlot, m, endTime));
              for (int i = 0; i < prog.getScreens(); i++) {
                nextFreeSlot[startSlot + i] = m + prog.getDuration(); // update next free slot for each screen
              }
              startSlot += prog.getScreens(); // shift to starting position of next selected programme
            }
          } else { // schedule selected programmes in descending duration order
            startSlot += filled; // ending position of 1st selected programme
            while (!selectedProgs.isEmpty()) {
              Programme prog = selectedProgs.remove(0);
              startSlot -= prog.getScreens(); // shift to starting position of current selected programme
              int endTime = Math.min(m + prog.getDuration(), mins); // in case programme exceeds allocated timeslot
              sessions.add(new Session(prog, startSlot, m, endTime));
              for (int i = 0; i < prog.getScreens(); i++) {
                nextFreeSlot[startSlot + i] = m + prog.getDuration(); // update next free slot for each screen
              }
            }
          }
          selectedProgs.clear();
          requeue(selectedPTs, pq);
          selectedPTs.clear();
        }
      }
    }
  }

  private PriorityQueue<ProgTimer> createQueue(List<Programme> progs) {
    PriorityQueue<ProgTimer> pq = new PriorityQueue<ProgTimer>();
    for (Programme prog : progs) {
      pq.add(new ProgTimer(prog));
    }
    return pq;
  }
  
  private void requeue(List<ProgTimer> pts, PriorityQueue<ProgTimer> pq) {
    for (ProgTimer pt : pts) {
      pt.setNextPlay();
      pq.add(pt);
    }
  }
  
  @Override
  public String toString() {
//    System.out.println(sessions);
    String[][] visNames = new String[mins][SCREENS];
    boolean[][] strokes = new boolean[mins][SCREENS];
    boolean[][] dashes = new boolean[mins][SCREENS];
    boolean[][] plusses = new boolean[mins][SCREENS];
    for (int r = 0; r < mins; r++) {
      for (int c = 0; c < SCREENS; c++) {
        visNames[r][c] = " NIL ";
        strokes[r][c] = true;
        dashes[r][c] = true;
        plusses[r][c] = true;
      }
    }
    for (Session session : sessions) {
      Visualisation vis = session.getVis();
      int startTime = session.getStartTime();
      int origEndTime = startTime + vis.getDuration();
      int startScreen = session.getStartScreen();
      int endScreen = session.getEndScreen();
      for (int m = startTime; m < Math.min(origEndTime, mins); m++) {
        for (int s = startScreen; s <= endScreen; s++) {
          visNames[m][s] = "     ";
        }
      }
      visNames[startTime][startScreen] = vis.toString();
      for (int m = startTime; m < Math.min(origEndTime, mins); m++) {
        for (int s = startScreen; s <= endScreen - 1; s++) {
          strokes[m][s] = false;
        }
      }
      for (int m = startTime; m < Math.min(origEndTime - 1, mins); m++) {
        for (int s = startScreen; s <= endScreen; s++) {
          dashes[m][s] = false;
        }
      }
      
      for (int m = startTime; m < Math.min(origEndTime - 1, mins); m++) {
        for (int s = startScreen; s <= endScreen - 1; s++) {
          plusses[m][s] = false;
        }
      }
    }
    StringBuilder spaces = new StringBuilder("       ");
    StringBuilder dash = new StringBuilder("-------");
    
    StringBuilder disp = new StringBuilder();
    disp.append("Screen:");
    for (int s = 0; s < SCREENS; s++) {
      disp.append("    " + (s + 1) + "   ");
    }
    disp.append("\n");

    disp.append(spaces + "+");
    for (int s = 0; s < SCREENS; s++) {
      disp.append(dash + "+");
    }
    disp.append(" 0 \n");

    for (int m = 0; m < mins; m++) {
      disp.append(spaces + "|");
      for (int s = 0; s < SCREENS; s++) {
        disp.append(" " + visNames[m][s] + " ");
        disp.append(strokes[m][s] ? "|" : " ");
      }
      disp.append("\n");

      disp.append(spaces + "+");
      for (int s = 0; s < SCREENS; s++) {
        disp.append(dashes[m][s] ? dash : spaces);
        disp.append(plusses[m][s] ? "+" : " ");
      }
      disp.append(" " + (m + 1) + "\n");
    }
    return disp.toString();
  }

  private class ProgTimer implements Comparable<ProgTimer> {
    Programme prog;
    float whenToPlay;
    
    ProgTimer(Programme prog) {
      this.prog = prog;
      whenToPlay = prog.getPeriod();
    }

    void setNextPlay() {
      whenToPlay += prog.getPeriod();
    }
    
    @Override
    public String toString() {
      return prog.toString() + ": " + whenToPlay;
    }
    
    @Override
    public int compareTo(ProgTimer p) {
      float timeDiff = whenToPlay - p.whenToPlay;
      return (int)Math.signum(Math.abs(timeDiff) < 0.00001 ? Math.random() * 2 - 1 : timeDiff);
    }
  }
  
}
