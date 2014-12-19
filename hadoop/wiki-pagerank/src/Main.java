/**
 *
 * @author cmantas
 */
public class Main {
    
    
    public static void main(String args[]) throws Exception{
        
        int iterations=20;
        
        String input=args[0], output=args[1], taskInput, taskOutput;
        boolean success;
        
        //Preprocess
        taskInput = input;
        taskOutput = output+"/initial";
        success = (new PreProcess(taskInput, taskOutput)).run();
        if(!success) throw new Exception("Preprocessing of xml input failed");
        
        //iteration
        for (int i = 0; i < iterations; i++) {
            taskInput=taskOutput;
            taskOutput="iter_"+(i+1);
            Iteration it=new Iteration(taskInput,taskOutput);
            success=it.run();
            if(!success) throw new Exception("Iteration "+i+" failed");
            it.delete(taskInput);//delete the previous step data
        }
        
        //order output
        taskInput=taskOutput;
        PageOrderer order = new PageOrderer(taskInput, output);
        success = order.run();
        if(!success) throw new Exception("Ordering of PageRanked pages failed");
        order.delete(taskInput);
    }
}
