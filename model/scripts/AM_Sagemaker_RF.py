import os
os.system('pip install --upgrade scikit-learn')
os.system('pip install imbalanced-learn')

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.svm import LinearSVC
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.exceptions import ConvergenceWarning
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import StackingClassifier
from imblearn.under_sampling import NearMiss
from imblearn.over_sampling import RandomOverSampler

from warnings import simplefilter
from sklearn.exceptions import ConvergenceWarning
simplefilter("ignore", category=ConvergenceWarning)
####################
import pandas as pd
import numpy as np
import argparse
import pandas as pd
import numpy as np
from pprint import pprint
import pip


def preprocess(df):
    df['cut'] = df['cut'].astype('category')
    df['color'] = df['color'].astype('category')
    df['clarity'] = df['clarity'].astype('category')
    df['carat_class'] = df['carat_class'].astype('category')
    
    df.dropna(inplace=True)
    
    for column in df.columns:
        if (df[column].dtype != float):
            continue
            
        Q1 = df[column].quantile(0.25)
        Q3 = df[column].quantile(0.75)
        IQR = Q3 - Q1
        P90 = df[column].quantile(0.90)
        df_out = df[df[column] > P90]
        df[column] = df[column].apply(lambda x: P90 if (x > P90) else x)
        df_out = df[df[column] > P90]
    
    #df['carat_class'] = df['carat_class'].map({'low':0, 'medium':1, 'high':2}).astype(float)
    df = pd.get_dummies(df, columns=['cut','color','clarity'])
    
    return df



if __name__ == '__main__':
    
    parser = argparse.ArgumentParser()

    # Sagemaker specific arguments. Defaults are set in the environment variables.
    parser.add_argument('--output-data-dir', type=str, default=os.environ.get('SM_OUTPUT_DATA_DIR'))
    parser.add_argument('--model-dir', type=str, default=os.environ.get('SM_MODEL_DIR'))
    parser.add_argument('--train', type=str, default=os.environ.get('SM_CHANNEL_TRAIN'))

    args = parser.parse_args()
    
    input_files = [ os.path.join(args.train, file) for file in os.listdir(args.train) ]
    
    train = pd.read_csv(input_files[0], engine='python')
    
    
    dataset = preprocess(train)

    X=dataset.drop(columns=['carat_class'])
    y=dataset['carat_class']

   
    #scikit classifier
    ros = RandomOverSampler(random_state=42)
    X_sample, y_sample = ros.fit_resample(X, y)
    estimators = [
         ('rf', RandomForestClassifier(n_estimators=10, random_state=42)),
         ('svr', make_pipeline(StandardScaler(),
                               LinearSVC(random_state=42)))
    ]
    clf = StackingClassifier(estimators=estimators, final_estimator=LogisticRegression() )
    

    
    print('######################################## START TRAIN ########################################')
    
    model = clf.fit(X_sample, y_sample)
    joblib.dump(model, os.path.join(args.model_dir, 'model.joblib'))
    
    print('######################################## FINISH TRAIN ########################################')
    

def model_fn(model_dir):
    model = joblib.load(os.path.join(model_dir, 'model.joblib'))
    return model


def input_fn(request_body, request_content_type):
    if request_content_type == 'text/csv':
        samples = []
        for r in request_body.split('\n'):
            samples.append(list(map(float, r.split(','))))
        return np.array(samples)
    else:
        raise ValueError('The model only supports text/csv input')


def predict_fn(input_data, model):
    return model.predict(input_data)


def output_fn(prediction, content_type):   
    results = [str(t) for t in prediction]
    #results = map({"0": "bad", "1": "good"}.get, results)
    return '\n'.join(results)

