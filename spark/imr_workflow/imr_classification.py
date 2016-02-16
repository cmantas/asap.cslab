"""
Classification in Spark
@author: Chris Mantas
@contact: the1pro@gmail.com
@since: Created on 2016-02-12
@todo: custom formats, break up big lines
@license: http://www.apache.org/licenses/LICENSE-2.0 Apache License
"""

from pyspark.mllib.classification import \
    LogisticRegressionWithLBFGS, LogisticRegressionModel
from imr_tools import *
from pyspark import SparkContext
from argparse import ArgumentParser

# ==================== Global Vars ============================ #
_INTERCEPT = True
_REGULARIZATION = None


# ====================  Helper Functions ====================== #

def train_model(training_rdd, **kwargs):
    """
    Train a classifier model using  an rdd training dataset
    :param training_rdd: the rdd of the training dataset
    :param kwargs: additional key-value params for the training (if any)
    :return:
    """
    return LogisticRegressionWithLBFGS.train(training_rdd,
                                             regType=_REGULARIZATION,
                                             intercept=_INTERCEPT,
                                             **kwargs)


def get_cli_args():
    """
    Defines the command-line arguments, parses the input and returns a
    namespace object with the parameters given by the user
    :return:
    """
    cli_parser = ArgumentParser(description='Classification on Spark')
    cli_parser.add_argument("operation",
                            help="the operation to run: 'train' or 'classify'")
    cli_parser.add_argument("input",
                            help="the input dataset (formatted as a tuple)")
    cli_parser.add_argument("-m", '--model', required=True,
                            help="a csv file holding the model weights")
    cli_parser.add_argument("-o", '--output',
                            help="the output location "
                                 "(in case of classify op)")
    cli_parser.add_argument("-l", '--labels', required=True,
                            help="a csv file holding all labels in dataset")
    cli_parser.add_argument("-c", '--category', type=int, default=1,
                            help="which category (label) to use [1-3]")
    cli_parser.add_argument("-u", "--update", action='store_true',
                            default=False, help="update a pre-existing model")
    cli_parser.add_argument("-e", "--evaluate", action='store_true',
                            default=False,
                            help="cross-evaluate the model on 20%% of input")

    return cli_parser.parse_args()


def calculate_error(valid_rdd, model):
    """
    Calculate the error ratio of a given model on a given RDD dataset
    :param valid_rdd: an RDD of LabeledPoints
    :param model: a classification model
    :return: a float in the [0-1] range
    """
    label_and_preds = valid_rdd.map(
            lambda p: (p.label, model.predict(p.features))
            )
    erroneous = label_and_preds.filter(lambda (l, p): l != p)
    return erroneous.count() / float(valid_rdd.count())


# ====================  Spark Jobs ====================== #

def perform_train_job(input_path, l_encoder,
                      initial_weights=None, evaluate=False, category=1):
    """
    Trains a Linear Regression model and returns its weights
    :param input_path: the input file-name (local or HDFS)
    :param l_encoder: The label encoder
    :param initial_weights: the initial LR model (weights) we will be enhancing
    :param evaluate: Whether or not to cross-evaluate the model on a 20% split
    :param category: the label category
    :return: a list of model weights for a Logistic Regression Model
    """

    # ----------------  Start Spark Job ----------------  #
    print("=============>  Train/Update Model  <=============")
    if "sc" not in globals():  # init the spark context
        print("---> Init. Spark Context")
        sc = SparkContext(appName="Train Logistic Regression (IMR)")

    raw_data = sc.textFile(input_path)  # the raw text input RDD


    entry_data = raw_data.map(parse_line)

    enc_entries = entry_data.map(
            lambda e: encode_entry_label(e, category, l_encoder)
    )

    # an RDD of Labeled Points
    all_data = enc_entries.map(lambda e: entry_to_labeled_point(e, category))

    if evaluate:  # choose the training data
        # split the dataset in training and validation sets
        (training_data, validation_data) = all_data.randomSplit([0.8, 0.2])
    else:
        # use the whole dataset
        training_data = all_data

    if initial_weights is None:
        print("---> Training Classification Model")
    else:
        print("---> Updating Classification Model")

    # ----------------   Do the training ----------------  #
    model = train_model(training_data, numClasses=len(l_encoder.classes_),
                        initialWeights=initial_weights)
    print("   > Done")

    # calculate training error
    print("---> Calculating Training Error")
    error = calculate_error(training_data, model)
    print("   > "+str(error))

    # if evaluate is given, calculate the evaluation error too
    if evaluate:
        print("---> Calculating Evaluation Error")
        error = calculate_error(validation_data, model)
        print("   > "+str(error))

    return model.weights


def perform_classification_job(input_path, encoder, model_weights,
                               output_path):
    """
    Classifies the entries of a dataset based on a model created from the
    weights given as an input
    :param input_path: the input (text) dataset location
    :param parser: The parser function to use for getting the features
    :param model_weights: The LR model weights

    :param output_path: The output dataset location
    :return: None
    """

    # ----------------   Start Spark Job ----------------  #
    print("===============>     Classify     <===============")
    if "sc" not in globals():  # init the spark context
        print("---> Init. Spark Context")
        sc = SparkContext(appName="Train Logistic Regression (IMR)")

    raw_data = sc.textFile(input_path)  # the raw text input RDD

    # the parser just needs to take the features from a text line
    parsing_mapper_func = get_features_from_line

    # an RDD of feature vectors
    feature_entries = raw_data.map(parsing_mapper_func)

    # hack to find out the number of features in the dataset
    feature_count = len(feature_entries.first())

    # ----------- Create a model from given weights ------------ #
    print("---> Re-creating the Model")
    model = LogisticRegressionModel(model_weights, _INTERCEPT,
                                    feature_count, len(encoder.classes_))

    def classifying_func(features):
        """
        A closure (function) using classify_line and the model and encoder
         that are available in this scope
        :param features:
        :return:
        """
        return classify_line(features, model, encoder)

    # ---------------- Do the classification ---------------- #
    print("---> Classifying the Input")
    labeled_entries = feature_entries.map(classifying_func)
    print("   > Done")

    # save the output as a text file
    labeled_entries.saveAsTextFile(output_path)


# =======================  MAIN ========================= #
if __name__ == "__main__":

    # get the command-line arguments
    args = get_cli_args()

    # create a label encoder from a local csv file that contains the set
    #   of available labels for this category
    l_encoder = create_encoders_from_label_csvs(args.labels)

    # ---------------  Choose the Operation to perform =-------------- #
    if args.operation.lower() == "train":
        # load initial weights if it's an update operation
        init_weights = load_model_weights(args.model) if args.update else None

        # do the train job
        model_weights = perform_train_job(args.input, l_encoder,
                                          initial_weights=init_weights,
                                          evaluate=args.evaluate,
                                          category=args.category)
        # save the model weights as a csv file
        save_model_weights(model_weights, args.model)

    elif args.operation.lower() == "classify":
        if not args.output:
            raise Exception("for classify operation, an output needs to be"
                            "specified")
        weights = load_model_weights(args.model)

        # do the classification job
        perform_classification_job(args.input, l_encoder,
                                   weights, args.output)
    else:
        print("I do not know operation: "+args.operation)
