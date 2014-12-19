import cslab.BasicTask;
import java.io.IOException;
import xmlTools.WikiLinksReducer;
import xmlTools.WikiPageLinksMapper;
import xmlTools.XmlInputFormat;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;

public class PreProcess extends BasicTask{
        
    
    public PreProcess(String args[]) throws IOException {
        super(args);
    }

    PreProcess(String input, String output) throws IOException {
        super(input, output);
    }
   
    

    @Override
    public void JobConfig() {
        
        // Input / Mapper
        job.setInputFormatClass(XmlInputFormat.class);
        job.setMapperClass(WikiPageLinksMapper.class);
        job.setMapOutputKeyClass(Text.class);        
        job.setOutputFormatClass(TextOutputFormat.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);
        job.setReducerClass(WikiLinksReducer.class);
    }

    @Override
    public String getJobName() {
        return "Processing Wikipedia XML input";
    }

    @Override
    public void envConfig() {
      conf.set(XmlInputFormat.START_TAG_KEY, "<page>");
      conf.set(XmlInputFormat.END_TAG_KEY, "</page>");
    }

    public static void main(String args[]) throws Exception {
        PreProcess job = new PreProcess(args);
        System.exit( job.run()?0:-1);
    }

}
