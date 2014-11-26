import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.PriorityQueue;

public class Scheduler2x2 {

  private static final int SCREENROWS = 2;
  private static final int SCREENCOLS = 2;
  private int mins;
  private List<Session> sessions = new ArrayList<Session>();

  public Scheduler2x2(int mins) {
    this.mins = mins;
    reset();
  }

  public void reset() {
    sessions.clear();
  }

  public void schedule(List<Programme> progs) {
    PriorityQueue<ProgTimer> pq = createQueue(progs);
    int[][] nextFreeTimeslot = new int[SCREENROWS][SCREENCOLS]; // tracks the next free slot for each screen
    for (int r = 0; r < SCREENROWS; r++) {
      for (int c = 0; c < SCREENCOLS; c++) {
        nextFreeTimeslot[r][c] = 0;
      }
    }
    List<ProgTimer> selectedPTs = new ArrayList<ProgTimer>(); // list of ProgTimers to requeue after scheduling
    List<Programme> selectedProgs = new ArrayList<Programme>(); // list of Programmes to schedule
    for (int current_time = 0; current_time < mins; current_time++) {
      for (int curr_row = 0; curr_row < SCREENROWS; curr_row++) { // curr_screen_row for free slots at current_time
        for (int curr_col = 0; curr_col < SCREENCOLS; curr_col++) { // curr_screen_col for free slots at current_time
        if (nextFreeTimeslot[curr_row][curr_col] <= current_time) { // free slot found
          int start_col = curr_col; // start of free slot
          int block_size;
          for (block_size = 1; curr_col + block_size < SCREENCOLS; block_size++) { // curr_col for consecutive free slots at current_time
            if (nextFreeTimeslot[curr_row][curr_col + block_size] > current_time) { // end of free block
              break;
            }
          }
          curr_col += block_size; // move curr_col to end of free block
          int filled_blocks = 0; // records number of filled_blocks slots in block
          while (!pq.isEmpty() && filled_blocks < block_size) { // select programmes to fill block
            ProgTimer pt = pq.peek();
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
          
//          int try_fill = 0;
//          while (filled_blocks < block_size && Programme.defProgs.length > 0 && try_fill < 3) { // fill remainder of block with default programmes
//            Programme defProg = Programme.defProgs[(int)(Math.random() * Programme.defProgs.length)];
//            try_fill++; // stop if no default programme that can fit is found after a few tries
//            if (filled_blocks + defProg.getScreens() <= block_size) { // selected programme can fit
//              selectedProgs.add(defProg);
//              filled_blocks += defProg.getScreens();
//              try_fill = 0; // reset and pick another default programme
//            }
//          }
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
          if (ascend) { // schedule selected programmes in ascending duration order
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
          } else { // schedule selected programmes in descending duration order
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
      selectedProgs.clear();
      selectedPTs.clear();
    }
  }

  private PriorityQueue<ProgTimer> createQueue(List<Programme> progs) {
    PriorityQueue<ProgTimer> pq = new PriorityQueue<ProgTimer>();
    for (Programme prog : progs) {
      pq.add(new ProgTimer(prog));
    }
    return pq;
  }
  
  private void requeue(ProgTimer pt, PriorityQueue<ProgTimer> pq) {
    pt.setNextPlay();
    pq.add(pt);
  }
  
  private void requeueAll(List<ProgTimer> pts, PriorityQueue<ProgTimer> pq) {
    for (ProgTimer pt : pts) {
      requeue(pt, pq);
    }
  }
  
  @Override
  public String toString() {
    System.out.println(sessions);
    String[][][] visNames = new String[mins][SCREENROWS][SCREENCOLS];
    boolean[][][] strokes = new boolean[mins][SCREENROWS][SCREENCOLS];
    boolean[][][] dashes = new boolean[mins][SCREENROWS][SCREENCOLS];
    boolean[][][] plusses = new boolean[mins][SCREENROWS][SCREENCOLS];
    for (int m = 0; m < mins; m++) {
      for (int r = 0; r < SCREENROWS; r++) {
        for (int c = 0; c < SCREENCOLS; c++) {
          visNames[m][r][c] = "$$$$$$$";
          strokes[m][r][c] = true;
          dashes[m][r][c] = true;
          plusses[m][r][c] = true;
        }
      }
    }
    for (Session session : sessions) {
      Visualisation vis = session.getVis();
      int startTime = session.getStartTime();
      int origEndTime = startTime + vis.getDuration();
      int startRow = session.getStartScreen() / SCREENCOLS;
      int endRow = session.getEndScreen() / SCREENCOLS;
      int startCol = session.getStartScreen() % SCREENCOLS;
      int endCol = session.getEndScreen() % SCREENCOLS;
      for (int current_time = startTime; current_time < Math.min(origEndTime, mins); current_time++) {
        for (int r = startRow; r <= endRow; r++) {
          for (int c = startCol; c <= endCol; c++) {
            visNames[current_time][r][c] = "       ";
          }
        }
      }
      visNames[startTime][startRow][startCol] = vis.toString();
      for (int current_time = startTime; current_time < Math.min(origEndTime, mins); current_time++) {
        for (int r = startRow; r <= endRow; r++) {
          for (int c = startCol; c <= endCol - 1; c++) {
            strokes[current_time][r][c] = false;
          }
        }
      }
      for (int current_time = startTime; current_time < Math.min(origEndTime - 1, mins); current_time++) {
        for (int r = startRow; r <= endRow; r++) {
          for (int c = startCol; c <= endCol; c++) {
            dashes[current_time][r][c] = false;
          }
        }
      }
      for (int current_time = startTime; current_time < Math.min(origEndTime - 1, mins); current_time++) {
        for (int r = startRow; r <= endRow; r++) {
          for (int c = startCol; c <= endCol - 1; c++) {
            plusses[current_time][r][c] = false;
          }
        }
      }
    }
    
    StringBuilder disp = new StringBuilder();
    String indent = "       ";
    String spaces = "         ";
    String gap = "  ";
    String dash = "---------";
    disp.append("Screen: ");
    for (int r = 0; r < SCREENROWS; r++) {
      for (int c = 0; c < SCREENCOLS; c++) {
        disp.append("    " + (SCREENCOLS * r + c + 1) + "     ");
      }
      disp.append(gap + " ");
    }
    disp.append("\n");

    disp.append(indent);
    for (int r = 0; r < SCREENROWS; r++) {
    disp.append("+");
      for (int c = 0; c < SCREENCOLS; c++) {
        disp.append(dash + "+");
      }
      if (r < SCREENROWS - 1) {
        disp.append(gap);
      }
    }
    disp.append(String.format(" %2d\n", 0));

    for (int current_time = 0; current_time < mins; current_time++) {
      disp.append(indent);
      for (int r = 0; r < SCREENROWS; r++) {
        disp.append("|");
        for (int c = 0; c < SCREENCOLS; c++) {
          disp.append(" " + visNames[current_time][r][c] + " ");
          disp.append(strokes[current_time][r][c] ? "|" : " ");
        }
        if (r < SCREENROWS - 1) {
          disp.append(gap);
        }
      }
      disp.append("\n");

      disp.append(indent);
      for (int r = 0; r < SCREENROWS; r++) {
        disp.append("+");
        for (int c = 0; c < SCREENCOLS; c++) {
          disp.append(dashes[current_time][r][c] ? dash : spaces);
          disp.append(plusses[current_time][r][c] ? "+" : " ");
        }
        if (r < SCREENROWS - 1) {
          disp.append(gap);
        }
      }
      disp.append(String.format(" %2d\n", current_time + 1));
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
