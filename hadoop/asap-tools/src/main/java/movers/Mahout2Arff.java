package movers;

import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.SequenceFile;
import org.apache.mahout.clustering.classify.WeightedPropertyVectorWritable;
import org.apache.mahout.common.Pair;
import static org.apache.mahout.common.iterator.sequencefile.PathFilters.logsCRCFilter;
import org.apache.mahout.common.iterator.sequencefile.PathType;
import org.apache.mahout.common.iterator.sequencefile.SequenceFileDirIterable;
import org.apache.mahout.math.NamedVector;
import org.apache.mahout.math.Vector;
import org.apache.mahout.math.Vector.Element;
import org.apache.mahout.math.VectorWritable;
/**
 *
 * @author cmantas
 */
public class Mahout2Arff {
    
    static Configuration conf=new Configuration();;
    static FileSystem fs;
    
    public static void writePreface(Writer writer) throws IOException{
      String preface="@relation '_home_cmantas_Data_docs_virt_dir-weka.filters.unsupervised.attribute.StringToWordVector-R1-W9999999-prune-rate-1.0-C-N0-L-stemmerweka.core.stemmers.NullStemmer-M1-tokenizerweka.core.tokenizers.WordTokenizer -delimiters \\\" \\\\r\\\\n\\\\t.,;:\\\\\\'\\\\\\\"()?\\\\\\\\!$#-0123456789/*\\\\\\%<>@[]+`~_=&^   \\\"";
      preface +="\n\n@attribute @@class@@ {text}\n";
      writer.write(preface);
    }
    
    public static int readDictionary(String dictPath, Writer writer) throws IOException {
        
        //init the reader
        SequenceFile.Reader reader = new SequenceFile.Reader(conf, SequenceFile.Reader.file(new Path(dictPath)));
        Text key = new Text();
        IntWritable val = new IntWritable();
        
        int termCount=0;
        while (reader.next(key, val)) {
            termCount++;
            writer.append("@attribute "+key + " numeric\n");
        }

        reader.close();
        return termCount;
    }
    
    public static int readVectors(String vectorsPath, Writer writer) throws IOException{
        int vectorCount=0;
        
        writer.append("\n@data\n\n");
        
        //iterable for sequence file dir
        SequenceFileDirIterable<Text, VectorWritable> sfd= new SequenceFileDirIterable<>(new Path(vectorsPath), PathType.LIST, logsCRCFilter(), conf);
        
        for (Pair<Text, VectorWritable> o: sfd){
            vectorCount++;
            Vector nv = o.getSecond().get();
            writer.append("{");
            boolean first=true;
            for(Element e:nv.all()){
                //get the value
                double value =e.get();
                if (value==0) continue;
                //construct the line to write
                String line="";
                if(!first) line+=",";
                else first=false;
                int index= 1+e.index(); //in weka, the document IDs start with one
                line +=index+" "+value;
                writer.append(line);
            }
            writer.append("}\n");
            
        }
        
        return vectorCount;
    }
    
    public static void main(String args[]) throws FileNotFoundException, IOException {
        
        // == read params
        String input = args[0];
        String output = args[1];

        //init the filesystem
        fs = FileSystem.get(conf);
        
        //create the output Writer        
        Writer writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(output), "utf-8"));
        
        writePreface(writer); //write the preface text
        
        //read and output the dict file
        int termCount = readDictionary(input+"/dictionary.file-0", writer);
        System.out.println("Read "+ termCount+" terms.");
        
        //read and output the vectors file        
        int vectorCount = readVectors(input+"/tfidf-vectors", writer);
        System.out.println("Read "+vectorCount+" document vectors");
        
        writer.close();
        
    }
}
