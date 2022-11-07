import java.util.Set;
import java.util.HashSet;
import java.util.Deque;
import java.util.ArrayDeque;
import java.util.List;
import java.util.ArrayList;
import java.util.Collections;

public class ProblemPancake extends Problem {
	
	public Object goalState;

    public ProblemPancake(int[] array) {
        List<Integer> initialState = new ArrayList<Integer>();
        List<Integer> goalState = new ArrayList<Integer>();

        for (int i=0; i < array.length; i++) {
            initialState.add(array[i]);
            goalState.add(array[i]);
        }
        Collections.sort(goalState);

        this.initialState = initialState;
        this.goalState = goalState;
    }
	
	boolean goal_test(Object state) {
		return state.equals(goalState);
	}

	Set<Object> getSuccessors(Object state) {

		Set<Object> set = new HashSet<Object>();
        ArrayList<Integer> s = ( ArrayList<Integer> ) state;

        ArrayList<Integer> test;

        for (int i=1; i<s.size(); i++) {
            test = getFlippedState(s, i);
            set.add(test);
        }
		return set;
	}
	
	double step_cost(Object fromState, Object toState) {
		return 1;
	}

	public double h(Object state) {

        ArrayList<Integer> s = ( ArrayList<Integer> ) state;
        double gap_count = 0;

        int j = 0;
        for (int i=1; i < s.size(); i++) {
            int gap = Math.abs(s.get(j) - s.get(i));
            if (gap > 1)
                gap_count++;
            j++;
        }
        return gap_count;
	}

    public ArrayList<Integer> getFlippedState(ArrayList<Integer> state, int index) {

        ArrayList<Integer> flippedState = new ArrayList<Integer>(state);

        int j = index;
        for (int i=0; i <= index; i++) {
            flippedState.set(j, state.get(i));
            j--;
        }
        return flippedState;
    }

	public static void main(String[] args) throws Exception {
        int[] start_array = {4,3,0,2,1};
		ProblemPancake problem = new ProblemPancake(start_array);

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