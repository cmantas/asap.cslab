import movers.Arff2Mahout;
import static java.util.Arrays.copyOfRange;
import movers.Mahout2Arff;

/**
 *
 * @author cmantas
 */
public class Main {
    
    public static void main(String args[]) throws Exception{
        String command = args[0];
        String [] newArgs =copyOfRange(args, 1, args.length);
        command = command.toLowerCase();
        switch (command){
            case "loaddir":
                LocalSeqDirectory.main(newArgs);
                break;
            case "seqinfo":
                SequenceInfo.main(newArgs);
                break;
            case "loadcsv":
                CSVLoader.main(newArgs);
                break;
            case "arff2mahout":
                Arff2Mahout.main(newArgs);
                break;
            case "mahout2arff":
                Mahout2Arff.main(newArgs);
                break;
            default:
                System.err.println("ERROR: I do not know command: "+command);
        }
    }
}
