package gr.ntua.cslab.asap;

/**
 * @file KMeans.java
 * @author Marcus Edel
 *
 * K-Means Clustering with weka.
 */
import java.io.File;
import weka.clusterers.SimpleKMeans;
import weka.core.Instance;
import weka.core.Instances;
import weka.core.converters.CSVLoader;

/**
 * This class use the weka libary to implement K-Means Clustering.
 */
public class Main {
  private static final String USAGE = "use parameters: <my_filepath.csv> <K>";
  static int K = 1;
  static String filePath;
  
  static void readParams(String args[]){
      K = Integer.parseInt(args[1]);
      filePath = args[0];
      
      System.out.println("K-means on file: "+filePath);
      System.out.println("For K: "+K);
  }
  
  
  public static void main(String args[]) {

      readParams(args);
      
    try {        
      
      CSVLoader loader = new CSVLoader();
       loader.setSource(new File(filePath));
       Instances data = loader.getDataSet();
       
     
      // Create the KMeans object.
      SimpleKMeans kmeans = new SimpleKMeans();
      kmeans.setNumClusters(K);
     
      // Gather parameters and validation of options.
      int maxIteration = 100;

     
     
      //TODO seed???
     //kmeans.setSeed(0);
          
      kmeans.setMaxIterations(maxIteration);     
      kmeans.setPreserveInstancesOrder(true);   
     
      // Perform K-Means clustering.
     
      kmeans.buildClusterer(data);
      
            // print out the cluster centroids
      Instances centroids = kmeans.getClusterCentroids();
      for (int i = 0; i <K; i++) {
          System.out.print("Cluser "+i+" size: "+kmeans.getClusterSizes()[i]); 
          System.out.println(" Centroid: "+ centroids.instance(i));
      }
      
//        Assignments:
//        int[] assignments = kmeans.getAssignments();
//        System.out.println("Length: "+assignments.length);
//        for (int i = 0; i < assignments.length; i++) {
//            System.out.println(assignments[i]);
//            
//        }
     
    } catch (IllegalArgumentException e) {
      System.err.println(USAGE);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}