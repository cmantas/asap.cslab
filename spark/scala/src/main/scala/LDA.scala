import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.SparkContext._
import org.apache.spark.mllib.clustering.LDA
import org.apache.spark.mllib.linalg.Vectors

/**
 * @author gsvic
 */


object LDA {
  def main(args: Array[String]){
    val conf = new SparkConf().setAppName("CSLab_LDA")
    val sc = new SparkContext(conf)
    
    val data = sc.textFile(args(0))
      .map(doc => Vectors.dense(doc.trim.split(' ').map(_.toDouble) ) )

    val corpus = data.zipWithIndex.map(_.swap).cache()
    
    val n = data.count()
    
    val model = new LDA().setK(10)
    
    model.run(corpus)
  }
}