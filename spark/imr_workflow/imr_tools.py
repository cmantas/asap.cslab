from ast import literal_eval


def create_label_encoder(labels):
    """
    Creates a label encoder from a list of labels
    :param labels: a list of integers
    :return: a LabelEncoder object
    """
    from sklearn.preprocessing import LabelEncoder
    encoder = LabelEncoder()
    encoder.fit(labels)
    return encoder


def get_labels_from_label_csv(file_name):
    """
    Reads a single-line csv file that contains labels and returns said labels
    :param file_name: a csv file
    :return: an iterable of integer labels
    """
    line = open(file_name).readlines()[0]
    labels = literal_eval(line)
    return labels


def create_encoders_from_label_csvs(*csvs):
    """
    Creates one or more label encoders from one or more csv filenames
    :param csvs: files with integer labels in a single line
    :return:
    """

    def create_one(csv):
        """
        helper function creating label encoder from single csv
        """
        labels = get_labels_from_label_csv(csv)
        l_encoder = create_label_encoder(labels)
        return l_encoder

    if len(csvs) > 1:
        return map(create_one, csvs)
    else:
        return create_one(csvs[0])


def get_features_from_line(line):
    """
    Given a text line it returns
     a) only the last element of the tuple if the line is a tuple.
        That element we assume to be a list of features.
     b) the line's elements if the line is not a tuple
    :param line:
    :return:
    """
    from ast import literal_eval
    entry = literal_eval(line)
    return entry[-1] if isinstance(entry, tuple) else entry


def line_to_labeled_point(line, category, label_encoder=None):
    """
    Creates a label point from a text line that is formated as a tuple
    :param line: line of format (3, 2, 1, [3,4,4 ..]), where the first entries
            in the tuple are labels, and the last entry a list of features
    :param category: which one of the labels in the tuple to keep for the
            labeled point (0 to 2 for imr dataset)
    :param label_encoder: an optional LabelEncoder object for the label value
    :return: a LabeledPoint
    """
    from ast import literal_eval
    from pyspark.mllib.classification import LabeledPoint

    entry = literal_eval(line)
    print "???? Transforming:,", entry[category]
    tst = (entry[category],)
    label = label_encoder.transform(tst)[0] if label_encoder \
            else entry[category]

    features = entry[-1]  # the last element in tuple is the feature list

    return LabeledPoint(label, features)  # return a new labelPoint


def save_model_weights(weights, filepath):
    """
    Saves the 'weights' list in file 'filepath'
    :param weights:
    :param filepath:
    :return:
    """
    with open(filepath, 'w+') as f:
        f.write(str(weights))


def load_model_weights(file_path):
    """
    Loads the weights of a model from a single-line csv file
    :param file_path:
    :return:
    """
    with open(file_path) as f:
        return literal_eval(f.read())


def get_encoding_parser(category_no, encoder):
        """
        Creates a closure that parses lines to LabeledPoints.
        Uses the category number of 'label' to chose a category label
        Also the 'encoder' to encode the categories to consecutive integers.
        :param category_no: the category number to choose
        :param encoder: a LabeledEncoder for the given label category
        :return: a function parsing a text line
        """
        return lambda line: line_to_labeled_point(line, category_no,
                                                  label_encoder=encoder)


def classify_line(features, model, l_encoder=None):
    """
    Classifies the features based on the given model.
    If a label encoder is specified, it reverses the encoding of the label
    :param features: a vector of features
    :param model: a Classification Model
    :param l_encoder: a LabelEncoder
    :return: a tuple of:    label, [feat1, feat2 ... featN]
    """
    encoded_prediction = model.predict(features)
    prediction = l_encoder.inverse_transform(encoded_prediction) \
        if l_encoder else encoded_prediction
    return prediction, features

