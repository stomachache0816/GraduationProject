import platform
import os
import csv
import scipy
import numpy as np
from glob import glob
from tqdm import tqdm
import json
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
import tensorflow as tf
from tensorflow import keras
from keras import Sequential
from keras.utils import to_categorical
from keras.layers import Dense, Flatten, Conv2D, MaxPooling2D, BatchNormalization, Activation
gpus = tf.config.experimental.list_physical_devices('GPU')
print(f"platform.python_version(): {platform.python_version()}")
print(f"np.version.version: {np.version.version}")
print(f"scipy.__version__: {scipy.__version__}")
print(f"tf.__version__: {tf.__version__}")
print(f"tf.config.list_physical_devices('GPU'): {tf.config.list_physical_devices('GPU')}")

npy_file_list = glob(f"{os.getcwd()}\\mfcc\\*.npy")

mfcc_list = []
for npy_file in tqdm(npy_file_list):
    mfcc = np.load(file=npy_file)
    mfcc_list.append(mfcc)
mfcc_list = np.array(mfcc_list)

scaler = StandardScaler()
scaler.fit(mfcc_list.reshape((mfcc_list.shape[0] * mfcc_list.shape[1], mfcc_list.shape[2])))
mfcc_list_scaled = []
for mfcc in mfcc_list:
    mfcc_list_scaled.append(scaler.transform(mfcc))
mfcc_list_scaled = np.array(mfcc_list_scaled)

label_pinyin_list = []
for npy_file in npy_file_list:
    label_pinyin = npy_file[npy_file.find("_") + 1:npy_file.find(".npy")]
    label_pinyin_list.append(label_pinyin)
label_pinyin_list = np.array(label_pinyin_list)

sample_list = glob(f"{os.getcwd()}\\samplePinyin\\Male\\*.wav")
label_dic: dict = {}
for i in range(len(sample_list)):
    label = sample_list[i][sample_list[i].find("_") + 1:sample_list[i].find(".wav")]
    label_dic[label] = i

label_int_list = []
for label_pinyin in label_pinyin_list:
    label_int = label_dic[label_pinyin]
    label_int_list.append(label_int)
label_int_list = np.array(label_int_list)


def get_cnn_model(input_shape, num_classes, learning_rate=0.001, num_filters=32, dense_units=256):
    cnn_model = Sequential()

    # 第一層捲積層
    cnn_model.add(Conv2D(num_filters, kernel_size=(3, 3), padding='same', input_shape=input_shape))
    cnn_model.add(BatchNormalization())
    cnn_model.add(Activation('relu'))
    cnn_model.add(Conv2D(num_filters, kernel_size=(3, 3), padding='same'))
    cnn_model.add(BatchNormalization())
    cnn_model.add(Activation('relu'))
    cnn_model.add(MaxPooling2D(pool_size=(2, 2)))

    # 第二層捲積層
    cnn_model.add(Conv2D(num_filters * 2, kernel_size=(3, 3), padding='same'))
    cnn_model.add(BatchNormalization())
    cnn_model.add(Activation('relu'))
    cnn_model.add(Conv2D(num_filters * 2, kernel_size=(3, 3), padding='same'))
    cnn_model.add(BatchNormalization())
    cnn_model.add(Activation('relu'))
    cnn_model.add(MaxPooling2D(pool_size=(2, 2)))

    # 第三層捲積層
    cnn_model.add(Conv2D(num_filters * 4, kernel_size=(3, 3), padding='same'))
    cnn_model.add(BatchNormalization())
    cnn_model.add(Activation('relu'))
    cnn_model.add(Conv2D(num_filters * 4, kernel_size=(3, 3), padding='same'))
    cnn_model.add(BatchNormalization())
    cnn_model.add(Activation('relu'))
    cnn_model.add(MaxPooling2D(pool_size=(2, 2)))

    # 展平
    cnn_model.add(Flatten())

    # 第一層全連接層
    cnn_model.add(Dense(dense_units))
    cnn_model.add(BatchNormalization())
    cnn_model.add(Activation('relu'))

    # 第二層全連接層
    cnn_model.add(Dense(dense_units * 2))
    cnn_model.add(BatchNormalization())
    cnn_model.add(Activation('relu'))

    # 第三層全連接層(長度同為1467個label)
    cnn_model.add(Dense(num_classes))

    # 表示為機率
    cnn_model.add(Activation('softmax'))

    cnn_model.compile(
        loss=keras.losses.categorical_crossentropy,
        optimizer=keras.optimizers.Adam(learning_rate=learning_rate),
        metrics=['accuracy']
    )

    return cnn_model

# 基本參數/資料
channel = 1
verbose = 2
num_classes = len(label_dic)
test_size = 0.2
mfcc_dim_1 = mfcc_list.shape[1]
mfcc_dim_2 = mfcc_list.shape[2]

X = mfcc_list_scaled
y = label_int_list

y_one_hot = to_categorical(y, num_classes=num_classes)

X_train, X_test, y_train, y_test = train_test_split(X, y_one_hot, test_size=test_size, random_state=42)

X_train = X_train.reshape(X_train.shape[0], mfcc_dim_1, mfcc_dim_2, channel)
X_test = X_test.reshape(X_test.shape[0], mfcc_dim_1, mfcc_dim_2, channel)

# 超參數
learning_rate_range = [1e-2, 1e-3, 1e-4, 1e-5]  # 學習率
num_filters_range = [32, 64, 128]  # 卷積層數量
dense_units_range = [256, 512]  # 全連接層數量
batch_size_range = [32, 64, 128]  # 批次大小
epochs_range = [200, 300, 500]  # 訓練輪數

params_names = [
    "data_amount",
    "learning_rate",
    "num_filters",
    "dense_unit",
    "batch_size",
    "epochs",
    "accuracy"
]

# 網格搜尋
folder = f"{os.getcwd()}\\hyper_parameters_record\\"
if not os.path.isdir(folder):
    os.mkdir(folder)

record_file_name = f"{os.getcwd()}\\hyper_parameters_record\\hyper_params_{mfcc_list.shape[0]}.csv"
with open(file=record_file_name, mode="a", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=params_names)
    writer.writeheader()

accuracies = []

max_accuracy: float = 0
best_params: dict = {}
for learning_rate in learning_rate_range:
    for num_filters in num_filters_range:
        for dense_unit in dense_units_range:
            for batch_size in batch_size_range:
                for epochs in epochs_range:
                    model = get_cnn_model(
                        input_shape=(mfcc_dim_1, mfcc_dim_2, channel),
                        num_classes=num_classes,
                        learning_rate=learning_rate,
                        num_filters=num_filters,
                        dense_units=dense_unit,
                    )

                    model_train_info = model.fit(X_train, y_train, batch_size=batch_size, epochs=epochs, verbose=verbose, validation_data=(X_test, y_test))

                    val_accuracies = model_train_info.history['val_accuracy']
                    current_max_accuracy = max(val_accuracies)
                    accuracies.append(current_max_accuracy)

                    parameters = {
                        "data_amount": mfcc_list.shape[0],
                        "learning_rate": learning_rate,
                        "num_filters": num_filters,
                        "dense_unit": dense_unit,
                        "batch_size": batch_size,
                        "epochs": epochs,
                        "accuracy": current_max_accuracy
                    }

                    with open(file=record_file_name, mode="a", newline="") as file:
                        writer = csv.DictWriter(file, fieldnames=parameters.keys())
                        writer.writerow(parameters)

                    if current_max_accuracy > max_accuracy:
                        max_accuracy = current_max_accuracy
                        best_params = parameters

print(max_accuracy)
print(best_params)

best_params["max_accuracy"] = max_accuracy
with open(f"{os.getcwd()}\\best_params.json", "w") as json_file:
    json.dump(best_params, json_file)
