package movers;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import org.apache.mahout.math.NamedVector;
import org.apache.mahout.math.RandomAccessSparseVector;

import sun.org.mozilla.javascript.internal.NativeArray;

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
        Double[] indexes=null, values=null;
        //eval indexes
        NativeArray nr = (NativeArray) engine.eval(s.substring(startOfIndexes, endOfIndexes+1));
        indexes =(Double[]) nr.toArray(new Double[nr.size()]);
        //eval values
        nr = (NativeArray)engine.eval(s.substring(startOfValues, endOfValues+1));
        values =(Double[]) nr.toArray(new Double[nr.size()]);
        
        //create an empty Mahout sparse vector with the size we know it has
        RandomAccessSparseVector vector = new RandomAccessSparseVector(indexes.length);
        
        //iterate indexes/values arrays and assign the nalues in the Mahout vector
        for(int i=0; i<indexes.length; i++)
            vector.setQuick(indexes[i].intValue(), values[i]);

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
