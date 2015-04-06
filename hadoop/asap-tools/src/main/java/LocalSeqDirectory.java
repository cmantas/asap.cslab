
import java.io.File;
import java.io.IOException;
import static java.nio.file.Files.readAllBytes;
import static java.nio.file.Paths.get;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.SequenceFile.Writer;
import org.apache.hadoop.io.Text;
import static java.util.Arrays.sort;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author cmantas
 */
public class LocalSeqDirectory {
    
    
    public static void main(String[] args) throws IOException{
        int maxCount=0;
        
        String localDirPath = args[0];
        String distrSeqDirPath = args[1];
        if(args.length>2) maxCount=Integer.parseInt(args[2]);
            
        File localDir = new File(localDirPath);
        Path seqFilePath = new Path(distrSeqDirPath);
        
        //init the seq Writer
        SequenceFile.Writer writer = SequenceFile.createWriter(
            new Configuration(),
            Writer.file(seqFilePath),
            Writer.keyClass(Text.class),
            Writer.valueClass(Text.class));
        
        
        //get files and sort
        File[] allFiles = localDir.listFiles();
        sort(allFiles);
        
        //iterate through files (swallow)
        int count = 0;
        for (File f : allFiles) {
            if (f.isFile()) {
                String contents = new String(readAllBytes(get(f.getAbsolutePath())));
                String baseName = f.getName();
                writer.append(new Text(baseName), new Text(contents));
                if (((count += 1) >= maxCount) && (maxCount != 0)) break;
            }
        }
        System.out.println("Read "+ count+" files");
        //close the seqFile writer
        writer.close();
                
                
    }
}
