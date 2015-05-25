package movers;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import static java.lang.Integer.valueOf;
import static java.lang.Double.valueOf;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedList;
import java.util.List;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import org.apache.mahout.math.NamedVector;
import org.apache.mahout.math.RandomAccessSparseVector;

//import sun.org.mozilla.javascript.internal.NativeArray;

/**
 *
 * @author cmantas
 */
public class SparkVecs2Mahout {
    

    public static RandomAccessSparseVector string2Vector(String s) throws ScriptException{

        
        //the start index (inside the string) of the indexes of the vector's values
        int startOfIndexes = s.indexOf('[');
        //the end of indexes
        int endOfIndexes = s.indexOf(']', startOfIndexes+1);
        
        //the start and end  index of values
        int startOfValues = s.indexOf('[', endOfIndexes+1);
        int endOfValues = s.indexOf(']', startOfValues+1);
        
        ScriptEngineManager manager = new ScriptEngineManager();
        ScriptEngine engine = manager.getEngineByName("js");
        LinkedList<Integer> indexes=new LinkedList();
        LinkedList<Double> values =new LinkedList();
        
        //read indexes
        String toConsume = s.substring(startOfIndexes+1, endOfIndexes);
        int prevDelim = -1, nextDelim=toConsume.indexOf(',');
        do{
            String sValue = toConsume.substring(prevDelim+1, nextDelim);
            indexes.add( Integer.valueOf(sValue));
            prevDelim = nextDelim; 
            nextDelim = toConsume.indexOf(',', prevDelim+1);               
        }while(nextDelim !=-1);

        //read values
        toConsume = s.substring(startOfValues+1, endOfValues);
        prevDelim = -1; nextDelim=toConsume.indexOf(',');
        do{
            String sValue = toConsume.substring(prevDelim+1, nextDelim);
            values.add( Double.valueOf(sValue));
            prevDelim = nextDelim; 
            nextDelim = toConsume.indexOf(',', prevDelim+1);                        
        }while(nextDelim !=-1);

        
        //create an empty Mahout sparse vector with the size we know it has
        RandomAccessSparseVector vector = new RandomAccessSparseVector(indexes.size());
        
        //iterate indexes/values arrays and assign the nalues in the Mahout vector
        for(int i=0; i<indexes.size(); i++)
            vector.setQuick(indexes.get(i), values.get(i));

        return vector;
    }
    
    public static void main(String args[]) throws ScriptException{
        String fname= "tmp";
       Path fpath = (new File(fname)).toPath();
        Charset charset = Charset.forName("US-ASCII");
        try (BufferedReader reader = Files.newBufferedReader(fpath, charset)) {
            String line = null;
            while ((line = reader.readLine()) != null) {
                RandomAccessSparseVector vector = string2Vector(line);
                NamedVector namedVector = new NamedVector(vector, "dummyName");
                System.out.println(namedVector);
            }
        } catch (IOException x) {
            System.err.format("IOException: %s%n", x);
}
    }
}
