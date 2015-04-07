import static java.util.Arrays.copyOfRange;

/**
 *
 * @author cmantas
 */
public class Main {
    
    public static void main(String args[]) throws Exception{
        String command = args[0];
        String [] newArgs =copyOfRange(args, 1, args.length);
        
        switch (command){
            case "loadDir":
                LocalSeqDirectory.main(newArgs);
                break;
            case "seqInfo":
                SequenceInfo.main(newArgs);
                break;
            case "loadCSV":
                CSVLoader.main(newArgs);
                break;
            default:
                System.err.println("I do not know command: "+command);
        }
    }
}
