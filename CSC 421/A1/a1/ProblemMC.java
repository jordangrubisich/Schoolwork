import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class ProblemMC extends Problem {
	
	public Object goalState;
	
	boolean goal_test(Object state) {
		return state.equals(goalState);
	}

	Set<Object> getSuccessors(Object state) {

		Set<Object> set = new HashSet<Object>();
		Map<String, Integer> s = ( HashMap<String,Integer> ) state;

		Map<String, Integer> bcs = new HashMap<String, Integer>(s); // boat crossed state
		Map<String, Integer> ss;

		int num_M = s.get("M");
		int num_C = s.get("C");
		boolean boat_on_left_bank = s.get("B") == 0;

 
		// boat is on the left bank, values increase
		if (boat_on_left_bank) {

			// set boat to cross
			bcs.put("B", 1);

			// 1 cannibal crosses
			ss = new HashMap<String, Integer>(bcs);
			if (num_C <= 2) {
				ss.put("C", num_C+1);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}

			// 2 cannibals cross
			ss = new HashMap<String, Integer>(bcs);
			if (num_C <= 1) {
				ss.put("C", num_C+2);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}

			// 1 missionary crosses
			ss = new HashMap<String, Integer>(bcs);
			if (num_M <= 2) {
				ss.put("M", num_M+1);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}

			// 2 missionaries cross
			ss = new HashMap<String, Integer>(bcs);
			if (num_M <= 1) {
				ss.put("M", num_M+2);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}

			// 1 cannibal and 1 missionary cross
			ss = new HashMap<String, Integer>(bcs);
			if (num_C <= 2 && num_M <= 2) {
				ss.put("C", num_C+1);
				ss.put("M", num_M+1);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}
		}

		// boat is on the right bank, values decrease
		else {

			// set boat to cross
			bcs.put("B", 0);

			// 1 cannibal crosses
			ss = new HashMap<String, Integer>(bcs);
			if (num_C >= 1) {
				ss.put("C", num_C-1);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}

			// 2 cannibals cross
			ss = new HashMap<String, Integer>(bcs);
			if (num_C >= 2) {
				ss.put("C", num_C-2);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}

			// 1 missionary crosses
			ss = new HashMap<String, Integer>(bcs);
			if (num_M >= 1) {
				ss.put("M", num_M-1);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}

			// 2 missionaries cross
			ss = new HashMap<String, Integer>(bcs);
			if (num_M >= 2) {
				ss.put("M", num_M-2);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}

			// 1 cannibal and 1 missionary cross
			ss = new HashMap<String, Integer>(bcs);
			if (num_C >= 1 && num_M >= 1) {
				ss.put("C", num_C-1);
				ss.put("M", num_M-1);
				// System.out.println(ss);
				if (validState(ss))
					set.add(ss);
			}
		}

		return set;
	}
	
	double step_cost(Object fromState, Object toState) {
		return 1;
	}

	public double h(Object state) {
		Map<String, Integer> s = ( HashMap<String,Integer> ) state;
		int total_crossed = s.get("M") + s.get("C");
		if (s.get("B") == 0) {
			return 9 - 2*(total_crossed);
		}
		else {
			return 12 - 2*(total_crossed);
		}
	}

	public boolean validState(Map<String, Integer> state) {
		if (state.get("B") == 0) {
			return state.get("M") >= state.get("C");
		}
		else {
			return state.get("C") >= state.get("M");
		}
	}

	public static void main(String[] args) throws Exception {
		ProblemMC problem = new ProblemMC();

        HashMap<String, Integer> start = new HashMap<String, Integer>();
        start.put("M", 0);
        start.put("C", 0);
        start.put("B", 0);
        HashMap<String, Integer> goal = new HashMap<String, Integer>();
        goal.put("M", 3);
        goal.put("C", 3);
        goal.put("B", 1);

		problem.initialState = start;
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