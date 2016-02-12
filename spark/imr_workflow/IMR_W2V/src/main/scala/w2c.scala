import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.mllib.feature.{Word2Vec, Word2VecModel}
import org.apache.spark.mllib.linalg
import org.apache.spark.util.{Vector => SV}


object w2cObj extends App{
  val inputPath = args(0)
  val outputPath = args(1)
  val sparkConf = new SparkConf().setAppName("IMR Word2Vec Workflow")
  val sc = new SparkContext(sparkConf)

  val input = sc.textFile(inputPath)
  val splitted = input.map(x =>x.split(";"))
  val docs = splitted.map{ x =>
    (x(0), x(1), x(2), x(3), x(4))
  }

  val docs_seq = docs.map( x => (x._1, x._2, x._3, x._4, x._5.split(" ").toSeq ) )
  val w2c = new Word2Vec().setVectorSize(200)
  val model = w2c.fit(docs_seq.map(_._5))

  val vectorized = docs_seq.map(x => (x._1, x._2, x._3, x._4, vectorizeDocument(x._5)))

  val vectorizeWord = (word: String) => {
    try{
      model.transform(word)
    } catch{
      case _: Exception => linalg.Vectors.zeros(200)
    }
  }

  val vectorizeDocument = (doc: Seq[String]) => {

    val bv = doc.map{x => vectorizeWord(x)}
      .map{doc => SV(doc.toArray)}
      .reduce(_+_) / doc.size

    linalg.Vectors.dense(bv.elements)
  }

  println(vectorized.first)
}
