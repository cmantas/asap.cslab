package movers;

import java.io.IOException;
import static movers.Arff2Mahout.fs;
import static movers.Mahout2Arff.conf;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.SequenceFile.Writer;
import org.apache.hadoop.io.Text;
import org.apache.mahout.common.Pair;
import static org.apache.mahout.common.iterator.sequencefile.PathFilters.logsCRCFilter;
import org.apache.mahout.common.iterator.sequencefile.PathType;
import org.apache.mahout.common.iterator.sequencefile.SequenceFileDirIterable;
import org.apache.mahout.math.RandomAccessSparseVector;
import org.apache.mahout.math.Vector;
import org.apache.mahout.math.VectorWritable;




public class Mahout2Spark {
    
    public static final int size = 1048576;
    
    public static String Vector2SparkString(Vector v) {
        String indexes="(1048576,[", values="[";
        
        for(Vector.Element e: v.all()){
            if (e.get()==0) continue;
            indexes += e.index()+",";
            values +=e.get()+",";
        }
        indexes = indexes.substring(0, indexes.length()-1);
        values = values.substring(0, values.length()-1);
        
        return indexes+"],"+values+"])";
    }
    
    
     public static int readVectors(String vectorsPath, Writer writer) throws IOException{
        int vectorCount=0;
                
        //iterable for sequence file dir
        SequenceFileDirIterable<Text, VectorWritable> sfd= new SequenceFileDirIterable<>(new Path(vectorsPath), PathType.LIST, logsCRCFilter(), conf);
        for (Pair<Text, VectorWritable> o: sfd){
            vectorCount++;
            Vector nv = o.getSecond().get();
            String vectorString = Vector2SparkString(nv);            
            writer.append(o.getFirst(), new Text(vectorString));
        }
        
        return vectorCount;
    }
    
    public static void main(String args[]) throws IOException{
        
        String input=null, output=null;
        
        double[] dv = {1,0,0,3,0,0,10};
        RandomAccessSparseVector dummy= new RandomAccessSparseVector(dv.length);
        dummy.assign(dv );
        System.out.println(Vector2SparkString(dummy));
        
        //init the writer for the vectors file
        Writer tfidfWriter = new SequenceFile.Writer(fs, conf,
                new Path(output), Text.class, Text.class);
        
        readVectors(input, tfidfWriter);
    }
}
