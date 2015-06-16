package movers;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.LinkedList;
import java.util.List;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.SequenceFile.Writer;
import static org.apache.hadoop.io.SequenceFile.createWriter;
import org.apache.mahout.clustering.lda.cvb.TopicModel;
import org.apache.mahout.math.NamedVector;
import org.apache.mahout.math.RandomAccessSparseVector;
import org.apache.mahout.math.VectorWritable;
import static org.apache.hadoop.io.SequenceFile.createWriter;
/**
 *
 * @author cmantas
 */
public class Arff2Spark {
    static Configuration conf = new Configuration();
    static FileSystem fs;
    
    
    // dummy class that represents the indexes and values of a sparse vector
    private static class mySparseVector{
        List<Integer> intexes;
        List<Double> values;

        public mySparseVector(List<Integer> intexes, List<Double> values) {
            this.intexes = intexes;
            this.values = values;
        }
        
    }
    
    public static int readTerms(BufferedReader reader) throws IOException{        
        String line, term;
        int termId=0;
        
        System.out.println("ignoring terms");
        return 0;
//        //read the terms
//        while((line=reader.readLine())!=null){
//            if(!line.startsWith("@attribute"))
//               if(line.startsWith("@data")) break; //end of dictinary
//               else continue;
//            if(line.contains("@@class@@")) continue;
//            
//            termId++; //new term
//            
//            //strip the term
//            int beginningOfTerm=11; // "@attribute" is 10 chars long, we will strip this and the following whitespace
//            int endOfTerm=line.indexOf("numeric");
//            term = line.substring(beginningOfTerm, endOfTerm);
//            
//            System.out.println(termId+" "+term);
//            //write it to hdfs
////            dictWriter.append(new Text(term), new IntWritable(termId));
//        }
//        
////        dictWriter.close();
//        return termId;
    }
    
    static mySparseVector vectorFromString(String s){
        
        int valueIdx=1, spaceIdx, comaIdx;
        int vectorIndex;
        double value;
        boolean done=false;
        
        LinkedList<Integer> indexes = new LinkedList();
        LinkedList<Double> values = new LinkedList();
        
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
            
            //keep the index/value
            indexes.add(vectorIndex);
            values.add(value);
            
            //move the index to the next value
            valueIdx=comaIdx+1;
        }
        
        return new mySparseVector(indexes, values);
    }
    
    
    static String vector2String(mySparseVector mv){
        String rv ="";
        rv+="(1048576,"+mv.intexes+","+mv.values+")";
        return rv;
    }
    
    public static int readVectors(BufferedReader reader, BufferedWriter writer) throws IOException{

        String line;
        int docId=0;
        
        //read the vectors
        while((line=reader.readLine())!=null){
            if(!line.startsWith("{")) continue;
            docId ++;
            String docIdName = String.format("%09d",docId); //mahout stores doc ids as Text
            
            //construct the tfidf vector
            mySparseVector myVec = vectorFromString(line);
            String outLine = vector2String(myVec);
            //write the vector
            writer.append(outLine+"\n");
        }

        return docId;
    }
    
        public static void main(String args[]) throws FileNotFoundException, IOException {
        
        // == read params
        String input = args[0];
        String output = args[1];
        
        //the local file reader
        BufferedReader reader =  new BufferedReader(new FileReader(input));
        
        //init the filesystem
        fs = FileSystem.get(conf);
        
        Path file = new Path(output);
        if ( fs.exists( file )) fs.delete( file, true ); 
        BufferedWriter tfidfWriter = new BufferedWriter( new OutputStreamWriter( fs.create(file), "UTF-8" ) );
        
        
        //read the dictionary DUMMY for now
        int termsCount = readTerms(reader);        
        System.out.println("Read "+termsCount+" terms.");
        
        //read the document vectors
        int docsCount = readVectors(reader, tfidfWriter);
        System.out.println("Read "+docsCount+" vectors");
        
        tfidfWriter.close();
    }
    
}
