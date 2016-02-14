import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.mllib.feature.{Word2Vec, Word2VecModel}
import org.apache.spark.mllib.linalg
import org.apache.spark.util.{Vector => SV}


object W2C extends App{
  val inputPath = args(0)
  val outputPath = args(1)
  val op = args(2)

  val sparkConf = new SparkConf().setAppName("IMR Word2Vec Workflow")
  val sc = new SparkContext(sparkConf)

  //Word2Vec model
  var model = null.asInstanceOf[Word2VecModel]

  //Loading input documents
  lazy val input = sc.textFile(inputPath)

  //Splitting input documents on ';'
  lazy val splitted = input.map(x =>x.split(";"))

  //Mapping each document into a tuple of format: (id, label1, label2, label3, text)
  lazy val docs = splitted.map{ x =>
    (x(0), x(1), x(2), x(3), x(4))
  }

  //Splitting and transforming each document into an array of words
  lazy val docs_seq = docs.map( x => (x._1, x._2, x._3, x._4, x._5.split(" ").toSeq ) )

  /**
    * Vectorize each document - Transforming it into a [[linalg.Vector]]
    * */
  lazy val vectorized = docs_seq.map(x => (x._1, x._2, x._3, x._4, vectorizeDocument(x._5)))

  /**
    * Vectorize each word - Transforming it into a [[linalg.Vector]] using [[Word2VecModel.transform()]]
    * */
  lazy val vectorizeWord = (word: String) => {
    try{
      model.transform(word)
    } catch{
      case _: Exception => linalg.Vectors.zeros(200)
    }
  }

  lazy val vectorizeDocument = (doc: Seq[String]) => {
    val bv = doc.map{x => vectorizeWord(x)}
      .map{doc => SV(doc.toArray)}
      .reduce(_+_) / doc.size

    linalg.Vectors.dense(bv.elements)
  }

  def trainAndSaveModel: Unit ={
    val w2c = new Word2Vec().setVectorSize(200)
    this.model = w2c.fit(this.docs_seq.map(_._5))
    this.model.save(sc, outputPath)
  }

  def saveVectors: Unit = {
    model = Word2VecModel.load(sc, inputPath)
    vectorized.saveAsTextFile(args(1))
  }


  op match {
    case "sm" => trainAndSaveModel
    case "sv" => saveVectors
    case _ => println("Invalid argument")
  }
}