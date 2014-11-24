import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.PriorityQueue;

public class Scheduler1xN {

  private static final int SCREENS = 4;
  private int mins;
  private List<Session> sessions = new ArrayList<Session>();

  public Scheduler1xN(int mins) {
    this.mins = mins;
    reset();
  }

  public void reset() {
    sessions.clear();
  }

  public void schedule(List<Programme> progs) {
    PriorityQueue<ProgTimer1xN> pq = createQueue(progs);
    int[] nextFreeTimeslot = new int[SCREENS]; // tracks the next free slot for each screen
    for (int s = 0; s < SCREENS; s++) {
      nextFreeTimeslot[s] = 0;
    }
    List<ProgTimer1xN> selectedPTs = new ArrayList<ProgTimer1xN>(); // list of ProgTimers to requeue after scheduling
    List<Programme> selectedProgs = new ArrayList<Programme>(); // list of Programmes to schedule
    for (int current_time = 0; current_time < mins; current_time++) {
      for (int curr_screen = 0; curr_screen < SCREENS; curr_screen++) { // curr_screen for free slots at time current_time
        if (nextFreeTimeslot[curr_screen] <= current_time) { // free slot found
          int start_screen = curr_screen; // start of free slot
          int block_size;
          for (block_size = 1; curr_screen + block_size < SCREENS; block_size++) { // curr_screen for consecutive free slots at time current_time
            if (nextFreeTimeslot[curr_screen + block_size] > current_time) { // end of free block
              break;
            }
          }
          curr_screen += block_size; // move curr_screen to end of free block
          int filled_blocks = 0; // records number of filled_blocks slots in block
          while (!pq.isEmpty() && filled_blocks < block_size) { // select programmes to fill block
            ProgTimer1xN pt = pq.peek();
            if (pt.prog.getScreens() > block_size - filled_blocks) { // selected programme is too big
              break;
            }
            pq.remove(); // remove selected programme from queue
            if (pt.prog.getDuration() <= 2 * (mins - current_time)) { // select programme if >= half can be played
              selectedProgs.add(pt.prog); // schedule programme
              filled_blocks += pt.prog.getScreens();
              selectedPTs.add(pt); // requeue programme
            } else {
              // programme cannot be selected to play at a later time anyway, don't bother requeueing
            }
          }
          
          int try_fill = 0;
          while (filled_blocks < block_size && Programme.defProgs.length > 0 && try_fill < 3) { // fill remainder of block with default programmes
            Programme defProg = Programme.defProgs[(int)(Math.random() * Programme.defProgs.length)];
            try_fill++; // stop if no default programme that can fit is found after a few tries
            if (filled_blocks + defProg.getScreens() <= block_size) { // selected programme can fit
              selectedProgs.add(defProg);
              filled_blocks += defProg.getScreens();
              try_fill = 0; // reset and pick another default programme
            }
          }
          Collections.sort(selectedProgs); // sort selected programmes in ascending duration order

          boolean ascend; // indicates if block should be filled from shortest to longest duration or vice versa
          if (start_screen == 0 && block_size < SCREENS ||
              start_screen > 0 && curr_screen < SCREENS &&
              nextFreeTimeslot[start_screen - 1] < nextFreeTimeslot[curr_screen]) { // better to align left ie. longest to shortest
            ascend = false;
          } else if (start_screen + block_size == SCREENS && block_size < SCREENS ||
              start_screen > 0 && curr_screen < SCREENS &&
              nextFreeTimeslot[start_screen - 1] > nextFreeTimeslot[curr_screen]) { // better to align right ie. shortest to longest
            ascend = true;
          } else { // no alignment preference
            ascend = Math.random() < 0.5;
          }
          if (ascend) { // schedule selected programmes in ascending duration order
            start_screen += block_size - filled_blocks; // starting position of 1st selected programme
            while (!selectedProgs.isEmpty()) {
              Programme prog = selectedProgs.remove(0);
              int prog_end_time = Math.min(current_time + prog.getDuration(), mins); // in case programme exceeds allocated timeslot
              sessions.add(new Session(prog, start_screen, current_time, prog_end_time));
              for (int i = 0; i < prog.getScreens(); i++) {
                nextFreeTimeslot[start_screen + i] = prog_end_time; // update next free slot for each screen
              }
              start_screen += prog.getScreens(); // shift to starting position of next selected programme
            }
          } else { // schedule selected programmes in descending duration order
            start_screen += filled_blocks; // ending position of 1st selected programme
            while (!selectedProgs.isEmpty()) {
              Programme prog = selectedProgs.remove(0);
              start_screen -= prog.getScreens(); // shift to starting position of current selected programme
              int prog_end_time = Math.min(current_time + prog.getDuration(), mins); // in case programme exceeds allocated timeslot
              sessions.add(new Session(prog, start_screen, current_time, prog_end_time));
              for (int i = 0; i < prog.getScreens(); i++) {
                nextFreeTimeslot[start_screen + i] = prog_end_time; // update next free slot for each screen
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

  private PriorityQueue<ProgTimer1xN> createQueue(List<Programme> progs) {
    PriorityQueue<ProgTimer1xN> pq = new PriorityQueue<ProgTimer1xN>();
    for (Programme prog : progs) {
      pq.add(new ProgTimer1xN(prog));
    }
    return pq;
  }
  
  private void requeue(List<ProgTimer1xN> pts, PriorityQueue<ProgTimer1xN> pq) {
    for (ProgTimer1xN pt : pts) {
      pt.setNextPlay();
      pq.add(pt);
    }
  }
  
  @Override
  public String toString() {
    System.out.println(sessions);
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
      for (int current_time = startTime; current_time < Math.min(origEndTime, mins); current_time++) {
        for (int s = startScreen; s <= endScreen; s++) {
          visNames[current_time][s] = "     ";
        }
      }
      visNames[startTime][startScreen] = vis.toString();
      for (int current_time = startTime; current_time < Math.min(origEndTime, mins); current_time++) {
        for (int s = startScreen; s <= endScreen - 1; s++) {
          strokes[current_time][s] = false;
        }
      }
      for (int current_time = startTime; current_time < Math.min(origEndTime - 1, mins); current_time++) {
        for (int s = startScreen; s <= endScreen; s++) {
          dashes[current_time][s] = false;
        }
      }
      
      for (int current_time = startTime; current_time < Math.min(origEndTime - 1, mins); current_time++) {
        for (int s = startScreen; s <= endScreen - 1; s++) {
          plusses[current_time][s] = false;
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

    for (int current_time = 0; current_time < mins; current_time++) {
      disp.append(spaces + "|");
      for (int s = 0; s < SCREENS; s++) {
        disp.append(" " + visNames[current_time][s] + " ");
        disp.append(strokes[current_time][s] ? "|" : " ");
      }
      disp.append("\n");

      disp.append(spaces + "+");
      for (int s = 0; s < SCREENS; s++) {
        disp.append(dashes[current_time][s] ? dash : spaces);
        disp.append(plusses[current_time][s] ? "+" : " ");
      }
      disp.append(" " + (current_time + 1) + "\n");
    }
    return disp.toString();
  }

  private class ProgTimer1xN implements Comparable<ProgTimer1xN> {
    Programme prog;
    float whenToPlay;
    
    ProgTimer1xN(Programme prog) {
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
    public int compareTo(ProgTimer1xN p) {
      float timeDiff = whenToPlay - p.whenToPlay;
      return (int)Math.signum(Math.abs(timeDiff) < 0.00001 ? Math.random() * 2 - 1 : timeDiff);
    }
  }
  
}
