import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.PriorityQueue;

public class SchedulerMxN {

  private static final int SCREENROWS = 2;
  private static final int SCREENCOLS = 4;
  private int mins;
  private List<Session> sessions = new ArrayList<Session>();

  public SchedulerMxN(int mins) {
    this.mins = mins;
    sessions = new ArrayList<Session>();
  }

  public void schedule(List<Programme> progs) {
    sessions.clear();
    PriorityQueue<ProgTimer> pq = createQueue(progs);
    int[][] nextFreeTimeslot = new int[SCREENROWS][SCREENCOLS]; // tracks the next free slot for each screen
    for (int r = 0; r < SCREENROWS; r++) {
      for (int c = 0; c < SCREENCOLS; c++) {
        nextFreeTimeslot[r][c] = 0;
      }
    }
    List<ProgTimer> selectedPTs = new ArrayList<ProgTimer>(); // ProgTimers selected for a certain time
    boolean multi_row = false; // indicates if a multirow programme is found
    for (int current_time = 0; current_time < mins; current_time++) {
      List<Integer> allRows = permutate(SCREENROWS);
      findSpace: for (int curr_row : allRows) { // pick a random row
        if (!multi_row) {
          for (int curr_col = 0; curr_col < SCREENCOLS; curr_col++) { // curr_col for free slots at current_time
            if (nextFreeTimeslot[curr_row][curr_col] <= current_time) { // free slot found
              int start_col = curr_col; // start of free slot
              int block_size;
              for (block_size = 1; curr_col + block_size < SCREENCOLS; block_size++) { // curr_col for consecutive free slots at current_time
                if (nextFreeTimeslot[curr_row][curr_col + block_size] > current_time) { // end of free block
                  break;
                }
              }
              curr_col += block_size; // move curr_col to end of free block
              List<Programme> selectedProgs = new ArrayList<Programme>(); // Programmes selected for a certain block
              int filled_blocks = 0; // records number of filled_blocks slots in block
              while (!pq.isEmpty() && filled_blocks < block_size) { // select programmes to fill block
                ProgTimer pt = pq.peek();
                int prog_screens = pt.prog.getScreens();
                if (prog_screens > SCREENCOLS) { // selected programme occupies >1 row
                  multi_row = true;
                  break;
                }
                if (pt.prog.getScreens() > block_size - filled_blocks || selectedPTs.contains(pt)) { // selected programme is too big or has already been selected
                  break;
                }
                pq.remove(); // remove selected programme from queue
                if (pt.prog.getDuration() <= 2 * (mins - current_time)) { // select programme if >= half can be played
                  selectedProgs.add(pt.prog); // schedule programme
                  selectedPTs.add(pt); // shortlist programme
                  requeue(pt, pq); // requeue programme
                  filled_blocks += pt.prog.getScreens();
                } else {
                  // programme cannot be selected to play at a later time anyway, don't bother requeueing
                }
              }

              Collections.sort(selectedProgs); // sort selected programmes in ascending duration order
              boolean ascend; // indicates if block should be filled from shortest to longest duration or vice versa
              if (start_col == 0 && block_size < SCREENCOLS ||
                  start_col > 0 && curr_col < SCREENCOLS &&
                  nextFreeTimeslot[curr_row][start_col - 1] < nextFreeTimeslot[curr_row][curr_col]) { // better to align left ie. longest to shortest
                ascend = false;
              } else if (start_col + block_size == SCREENCOLS && block_size < SCREENCOLS ||
                  start_col > 0 && curr_col < SCREENCOLS &&
                  nextFreeTimeslot[curr_row][start_col - 1] > nextFreeTimeslot[curr_row][curr_col]) { // better to align right ie. shortest to longest
                ascend = true;
              } else { // no alignment preference
                ascend = Math.random() < 0.5;
              }
              if (ascend) { // schedule and clear selected programmes in ascending duration order
                start_col += block_size - filled_blocks; // starting position of 1st selected programme
                while (!selectedProgs.isEmpty()) {
                  Programme prog = selectedProgs.remove(0);
                  int prog_end_time = Math.min(current_time + prog.getDuration(), mins); // in case programme exceeds allocated timeslot
                  sessions.add(new Session(prog, SCREENCOLS * curr_row + start_col, current_time, prog_end_time));
                  for (int i = 0; i < prog.getScreens(); i++) {
                    nextFreeTimeslot[curr_row][start_col + i] = prog_end_time; // update next free slot for each screen
                  }
                  start_col += prog.getScreens(); // shift to starting position of next selected programme
                }
              } else { // schedule and clear selected programmes in descending duration order
                start_col += filled_blocks; // ending position of 1st selected programme
                while (!selectedProgs.isEmpty()) {
                  Programme prog = selectedProgs.remove(0);
                  start_col -= prog.getScreens(); // shift to starting position of current selected programme
                  int prog_end_time = Math.min(current_time + prog.getDuration(), mins); // in case programme exceeds allocated timeslot
                  sessions.add(new Session(prog, SCREENCOLS * curr_row + start_col, current_time, prog_end_time));
                  for (int i = 0; i < prog.getScreens(); i++) {
                    nextFreeTimeslot[curr_row][start_col + i] = prog_end_time; // update next free slot for each screen
                  }
                }
              }
            }
          }
        }
        if (multi_row) { // multi-row mode, treat screens as 1 very long row
          ProgTimer pt = pq.peek();
          int prog_rows = pt.prog.getScreens() / SCREENCOLS;
          if (curr_row + prog_rows <= SCREENROWS) { // enough rows for multi-row programme
            for (int r = 0; r < prog_rows; r++) {
              for (int curr_col = 0; curr_col < SCREENCOLS; curr_col++) {
                if (nextFreeTimeslot[curr_row + r][curr_col] > current_time) { // free slot not found
                  continue findSpace;
                }
              }
            }
            pq.remove();
            if (pt.prog.getDuration() <= 2 * (mins - current_time)) { // select programme if >= half can be played
              selectedPTs.add(pt); // shortlist programme
              requeue(pt, pq); // requeue programme
              int prog_end_time = Math.min(current_time + pt.prog.getDuration(), mins); // in case programme exceeds allocated timeslot
              sessions.add(new Session(pt.prog, SCREENCOLS * curr_row, current_time, prog_end_time));
              for (int r = 0; r < prog_rows; r++) {
                for (int curr_col = 0; curr_col < SCREENCOLS; curr_col++) {
                  nextFreeTimeslot[curr_row + r][curr_col] = prog_end_time; // update next free slot for each screen
                }
              }
              multi_row = false;
            } else {
              // programme cannot be selected to play at a later time anyway, don't bother requeueing
            }
          }
        }
      }
      selectedPTs.clear();
    }
    System.out.println(this);
  }
  
  private PriorityQueue<ProgTimer> createQueue(List<Programme> progs) {
    PriorityQueue<ProgTimer> pq = new PriorityQueue<ProgTimer>();
    for (Programme prog : progs) {
      int prog_screens = prog.getScreens();
      if (prog_screens > SCREENROWS * SCREENCOLS) { // force-fit the programme into the screens available
        prog.setScreens(SCREENROWS * SCREENCOLS); // rounds down number of screens
      } else if (prog_screens > SCREENCOLS) { // force-fit the programme into the screens available
        prog.setScreens(prog_screens - prog_screens % SCREENCOLS); // rounds down number of screens
      }
      pq.add(new ProgTimer(prog));
    }
    return pq;
  }
  
  private List<Integer> permutate(int num) {
    List<Integer> list = new ArrayList<Integer>();
    for (int i = 0; i < num; i++) {
      list.add(i);
    }
    Collections.shuffle(list);
    return list;
  }
  
  private void requeue(ProgTimer pt, PriorityQueue<ProgTimer> pq) {
    pt.setNextPlay();
    pq.add(pt);
  }
  
  @Override
  public String toString() {
    System.out.println(sessions);
    String[][] visNames = new String[mins][SCREENROWS * SCREENCOLS];
    boolean[][] strokes = new boolean[mins][SCREENROWS * SCREENCOLS];
    boolean[][] dashes = new boolean[mins][SCREENROWS * SCREENCOLS];
    boolean[][] plusses = new boolean[mins][SCREENROWS * SCREENCOLS];
    for (int m = 0; m < mins; m++) {
      for (int s = 0; s < SCREENROWS * SCREENCOLS; s++) {
        visNames[m][s] = "$$$$$$$";
        strokes[m][s] = true;
        dashes[m][s] = true;
        plusses[m][s] = true;
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
          visNames[m][s] = "       ";
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
    
    StringBuilder disp = new StringBuilder();
    String indent = "       ";
    String spaces = "         ";
    String dash = "---------";
    disp.append("Screen: ");
    for (int s = 0; s < SCREENROWS * SCREENCOLS; s++) {
      disp.append("    " + (s + 1) + "     ");
    }
    disp.append("\n");

    disp.append(indent + "+");
    for (int s = 0; s < SCREENROWS * SCREENCOLS; s++) {
      disp.append(dash + "+");
    }
    disp.append(String.format(" %2d\n", 0));

    for (int m = 0; m < mins; m++) {
      disp.append(indent + "|");
      for (int s = 0; s < SCREENROWS * SCREENCOLS; s++) {
        disp.append(" " + visNames[m][s] + " ");
        disp.append(strokes[m][s] ? "|" : " ");
      }
      disp.append("\n");

      disp.append(indent + "+");
      for (int s = 0; s < SCREENROWS * SCREENCOLS; s++) {
        disp.append(dashes[m][s] ? dash : spaces);
        disp.append(plusses[m][s] ? "+" : " ");
      }
      disp.append(String.format(" %2d\n", m + 1));
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
