import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class ProblemWGC extends Problem {

    public Object goalState;

	boolean goal_test(Object state) {
        return state.equals(goalState);
	}

	Set<Object> getSuccessors(Object state) {

        Set<Object> set = new HashSet<Object>();
		Map<String, Boolean> s = ( HashMap<String, Boolean> ) state;

		Map<String, Boolean> bcs = new HashMap<String, Boolean>(s); // boat crossed state
		Map<String, Boolean> ss;

        boolean wolf_at_finish = s.get("W");
		boolean goat_at_finish = s.get("G");
        boolean cabbage_at_finish = s.get("C");
		boolean boat_at_finish = s.get("B");

        if (boat_at_finish) {

            bcs.put("B", false);    // boat back to start
            
            // only boat moves banks
            ss = new HashMap<String, Boolean>(bcs);
            if (validState(ss))
                set.add(ss);

            // the boat and wolf move to start bank
            ss = new HashMap<String, Boolean>(bcs);
            if (wolf_at_finish) {
                ss.put("W", false);
                if (validState(ss))
                    set.add(ss);
            }

            // the boat and goat move to start bank
            ss = new HashMap<String, Boolean>(bcs);
            if (goat_at_finish) {
                ss.put("G", false);
                if (validState(ss))
                    set.add(ss);
            }

            // the boat and cabbage move to start bank
            ss = new HashMap<String, Boolean>(bcs);
            if (cabbage_at_finish) {
                ss.put("C", false);
                if (validState(ss))
                    set.add(ss);
            }
        }
        else {

            bcs.put("B", true);     // boat to finish

            // only boat moves banks
            ss = new HashMap<String, Boolean>(bcs); 
            if (validState(ss))
                set.add(ss);

            // the boat and wolf move to finish bank
            ss = new HashMap<String, Boolean>(bcs);
            if (!wolf_at_finish) {
                ss.put("W", true);
                if (validState(ss))
                    set.add(ss);
            }

            // the boat and goat move to finish bank
            ss = new HashMap<String, Boolean>(bcs);
            if (!goat_at_finish) {
                ss.put("G", true);
                if (validState(ss))
                    set.add(ss);
            }

            // the boat and cabbage move to start bank
            ss = new HashMap<String, Boolean>(bcs);
            if (!cabbage_at_finish) {
                ss.put("C", true);
                if (validState(ss))
                    set.add(ss);
            }
        }

        return set;
	}

	double step_cost(Object fromState, Object toState) { return 1; }

	public double h(Object state) {
        Map<String, Boolean> s = ( HashMap<String,Boolean> ) state;
        double wolf_cabbage_not_crossed = 0;
        if (!s.get("W")) { wolf_cabbage_not_crossed++; }
        if (!s.get("C")) { wolf_cabbage_not_crossed++; }

        if (s.get("B")) {
            return 2 + 2*wolf_cabbage_not_crossed;
        }
        return 1 + 2*wolf_cabbage_not_crossed;
    }

    public boolean validState(Map<String, Boolean> state) {
		if (state.get("B")) {
			return state.get("G") || ( state.get("W") && state.get("C") );
		}
		return !state.get("G") || ( !state.get("W") && !state.get("C") );
	}

	public static void main(String[] args) throws Exception {
		ProblemWGC problem = new ProblemWGC();

        Map<String, Boolean> start = new HashMap<String, Boolean>();
        start.put("W", false);
        start.put("G", false);
        start.put("C", false);
        start.put("B", false);

        problem.initialState = start;
        
        Map<String, Boolean> goal = new HashMap<String, Boolean>();
        goal.put("W", true);
        goal.put("G", true);
        goal.put("C", true);
        goal.put("B", true);

        problem.goalState = goal;
		
		Search search  = new Search(problem);
		
		System.out.println("TreeSearch------------------------");
		System.out.println("BreadthFirstTreeSearch:\t\t" + search.BreadthFirstTreeSearch());
		System.out.println("UniformCostTreeSearch:\t\t" + search.UniformCostTreeSearch());
		System.out.println("DepthFirstTreeSearch:\t\t" + search.DepthFirstTreeSearch());
		System.out.println("GreedyBestFirstTreeSearch:\t" + search.GreedyBestFirstTreeSearch());
		System.out.println("AstarTreeSearch:\t\t" + search.AstarTreeSearch());
		
		System.out.println("\n\nGraphSearch----------------------");
		System.out.println("BreadthFirstGraphSearch:\t" + search.BreadthFirstGraphSearch());
		System.out.println("UniformCostGraphSearch:\t\t" + search.UniformCostGraphSearch());
		System.out.println("DepthFirstGraphSearch:\t\t" + search.DepthFirstGraphSearch());
		System.out.println("GreedyBestGraphSearch:\t\t" + search.GreedyBestFirstGraphSearch());
		System.out.println("AstarGraphSearch:\t\t" + search.AstarGraphSearch());
		
		System.out.println("\n\nIterativeDeepening----------------------");
		System.out.println("IterativeDeepeningTreeSearch:\t" + search.IterativeDeepeningTreeSearch());
		System.out.println("IterativeDeepeningGraphSearch:\t" + search.IterativeDeepeningGraphSearch());
	}
}