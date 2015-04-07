
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.SequenceFile;
import org.apache.mahout.math.RandomAccessSparseVector;
import org.apache.mahout.math.Vector;
import org.apache.mahout.math.VectorWritable;
;

public class CSVLoader {

    public static void main(String args[]) throws FileNotFoundException, IOException {

        String input = args[0];
        String output = args[1];

        Configuration conf;
        conf = new Configuration();
        FileSystem fs = FileSystem.get(conf);

        try (
                BufferedReader reader =  new BufferedReader(new InputStreamReader(fs.open(new Path(input))));
                SequenceFile.Writer writer = new SequenceFile.Writer(fs, conf, new Path(output), LongWritable.class, VectorWritable.class)) {
            String line;
            long counter = 0;
            while ((line = reader.readLine()) != null) {
                String[] c = line.split(",");
                if (c.length > 1) {
                    double[] d = new double[c.length];
                    for (int i = 0; i < c.length; i++) {
                        d[i] = Double.parseDouble(c[i]);
                    }
                    Vector vec = new RandomAccessSparseVector(c.length);
                    vec.assign(d);

                    VectorWritable writable = new VectorWritable();
                    writable.set(vec);
                    writer.append(new LongWritable(counter++), writable);
                }
            }
            writer.close();
        }
    }
}
