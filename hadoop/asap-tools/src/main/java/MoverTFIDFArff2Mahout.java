import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.SequenceFile;
import org.apache.mahout.math.NamedVector;
import org.apache.mahout.math.RandomAccessSparseVector;
import org.apache.mahout.math.VectorWritable;
;

/**
 *
 * @author cmantas
 */
public class MoverTFIDFArff2Mahout {
    
    final static int maxFeatures = 1000000;
    static Configuration conf=new Configuration();;
    static FileSystem fs;
    
    public static int readTerms(BufferedReader reader, String output) throws IOException{

        //writer for the term dictionary
        SequenceFile.Writer dictWriter = new SequenceFile.Writer(fs, conf, 
                new Path(output),Text.class, IntWritable.class);
        
        String line, term;
        int termId=0;
        
        //read the terms
        while((line=reader.readLine())!=null){
            if(!line.startsWith("@attribute"))
               if(line.startsWith("@data")) break; //end of dictinary
               else continue;
            if(line.contains("@@class@@")) continue;
            
            termId++; //new term
            
            //strip the term
            int beginningOfTerm=11; // "@attribute" is 10 chars long, we will strip this and the following whitespace
            int endOfTerm=line.indexOf("numeric");
            term = line.substring(beginningOfTerm, endOfTerm);
            
            //write it to hdfs
            dictWriter.append(new Text(term), new IntWritable(termId));
        }
        
        dictWriter.close();
        return termId;
    }
    
    public static double[] doubleFromString(String s){
        double d[] =new double[maxFeatures]; //array of zeros
        int valueIdx=1, spaceIdx, comaIdx;
        int vectorIndex;
        double value;
        boolean done=false;
        
        //read all pairs of index/value
        while(!done){
            //find the vector index of this value
            spaceIdx=s.indexOf(" ", valueIdx);
            vectorIndex = Integer.parseInt(s.substring(valueIdx,spaceIdx));
            
            //find the value
            comaIdx=s.indexOf(",", spaceIdx+1);
            if(comaIdx==-1){
                done=true;
                comaIdx=s.length()-1;
            }
            value = Double.parseDouble(s.substring(spaceIdx+1, comaIdx));
            
            //assign the value to the actual vector
            d[vectorIndex] = value;
            
            //move the index to the next value
            valueIdx=comaIdx+1;
        }
        
        return d;
    }
    
    public static int readVectors(BufferedReader reader, String output) throws IOException{

        //init the writer for the vectors file
        SequenceFile.Writer tfidfWriter = new SequenceFile.Writer(fs, conf,
                new Path(output), Text.class, VectorWritable.class);
        
        String line;
        int docId=0;
        
        //read the vectors
        while((line=reader.readLine())!=null){
            if(!line.startsWith("{")) continue;
            docId ++;
            String docIdName = String.format("%09d",docId); //mahout stores doc ids as Text
            
            //construct the tfidf vector
            double values[] = doubleFromString(line);
            RandomAccessSparseVector vector = new RandomAccessSparseVector(values.length);
            vector.assign(values);
            NamedVector namedVector = new NamedVector(vector,docIdName);
            
            //write the vector
            tfidfWriter.append(new Text(docIdName), new VectorWritable(namedVector));
        }
        
        tfidfWriter.close();
        return docId;
    }
    
    public static void main(String args[]) throws FileNotFoundException, IOException {
        
        // == read params
//        String input = "/tmp/kmeans_text_weka/tf_idf_data.arff";
//        String output = "/tmp/myTestTfidf";
        String input = args[0];
        String output = args[1];

        
        
        //the local file reader
        BufferedReader reader =  new BufferedReader(new FileReader(input));
        
        //init the filesystem
        fs = FileSystem.get(conf);
        
        //read the dictionary
        int termsCount = readTerms(reader, output+"_dict");        
        System.out.println("Read "+termsCount+" terms.");
        
        //read the document vectors
        int docsCount = readVectors(reader, output+"_vectors");
        System.out.println("Read "+docsCount+" vectors");
    }
}
