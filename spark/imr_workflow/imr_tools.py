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


def parse_line(line):
    from ast import literal_eval
    try:
        entry = literal_eval(line)
        if not isinstance(entry, tuple):
            raise Exception("Input parsed, but is not a tuple")
    except:
        raise Exception("Could not evaluate (parse) input into an object")
    return entry


def encode_entry_label(entry, category, label_encoder):
    entry = list(entry)
    tst = (entry[category],)  # workaround: add label into a tuple
    #  avoids 'int not iterable' exception in
    #  label_encoder.transform
    label = label_encoder.transform(tst)[0]

    entry[category] = label
    return entry


def entry_to_labeled_point(entry, category):
    """
    Creates a label point from a text line that is formated as a tuple
    :param line: line of format (3, 2, 1, [3,4,4 ..]), where the first entries
            in the tuple are labels, and the last entry a list of features
    :param category: which one of the labels in the tuple to keep for the
            labeled point (0 to 2 for imr dataset)

    :return: a LabeledPoint
    """

    from pyspark.mllib.classification import LabeledPoint

    label = entry[category]
    features = entry[-1]
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

