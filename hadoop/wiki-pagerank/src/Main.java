/**
 *
 * @author cmantas
 */
public class Main {
    
    
    public static void main(String args[]) throws Exception{
        
        int iterations=20;
        
        String input=args[0], output=args[1], taskInput, taskOutput;
        boolean success;
        
        if (args.length>2) iterations = Integer.parseInt(args[2]);
        
        //=========  Preprocess Task =========================================
        taskInput = input;
        taskOutput = output+"/initial";
        success = (new PreProcessTask(taskInput, taskOutput)).run();
        if(!success) throw new Exception("Preprocessing of xml input failed");
        
        
//        //=========  PageRank Iterations' Tasks ==============================
//        //iteration
//        for (int i = 0; i < iterations; i++) {
//            taskInput = taskOutput;    // this iteration will get as input 
//                                       // the previous iterations's output 
//            taskOutput="iter_"+(i+1);  //The output of this iteration
//            
//            //init and run the itrerative step
//            Iteration it=new Iteration(taskInput,taskOutput);
//            success=it.run();
//            if(!success) throw new Exception("Iteration "+i+" failed");
//            it.delete(taskInput);      //delete the previous step's data
//        }
//
//        //=========  Ordering the PR vector Task =============================
//        //order output
//        taskInput=taskOutput;
//        PageOrderer order = new PageOrderer(taskInput, output);
//        success = order.run();
//        if(!success) throw new Exception("Ordering of PageRanked pages failed");
//        order.delete(taskInput);
    }
}
