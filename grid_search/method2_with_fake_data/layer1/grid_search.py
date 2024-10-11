import pandas as pd
from glob import glob
from tqdm import tqdm
import requests
import json
from model_training_process import *
import os
import csv

class_df = pd.read_csv(filepath_or_buffer="..\\..\\..\\cnn_method2\\tables\\corrected_class_df_pinyin_label_table.csv")

npy_file_path = glob("..\\..\\..\\data\\*EduVer\\*.npy", recursive=True)

npy_file_path_selected = list()
for npy_file in npy_file_path:
    pinyin = npy_file.split("_")[1]
    pinyin_non_accent = pinyin[:-1] if pinyin[-1].isdigit() else pinyin
    if pinyin_non_accent in list(class_df["pinyin"]):
        npy_file_path_selected.append(npy_file)

data_class_label = list()
for npy_file in tqdm(npy_file_path_selected):
    pinyin = npy_file.split("_")[1]
    pinyin_non_accent = pinyin[:-1] if pinyin[-1].isdigit() else pinyin
    class_label = class_df.loc[class_df["pinyin"] == pinyin_non_accent, "class_label"].iloc[0]
    data_class_label.append(class_label)
data_class_label = np.array(data_class_label)

mfcc_matrix_list = list()
for npy_file in tqdm(npy_file_path_selected):
    mfcc_matrix = np.load(npy_file)
    mfcc_matrix_list.append(mfcc_matrix)
mfcc_matrix_list = np.array(mfcc_matrix_list)

channel = 1
verbose = 2
num_classes = len(class_df.index)
test_size = 0.2
mfcc_dim_1 = mfcc_matrix_list.shape[1]
mfcc_dim_2 = mfcc_matrix_list.shape[2]

# 超參數
learning_rate_range = [1e-3, 1e-4, 1e-5]  # 學習率
num_filters_range = [32, 64, 128]  # 卷積層數量
dense_units_range = [256, 512]  # 全連接層數量
batch_size_range = [32, 64, 128]  # 批次大小
epochs_range = [250, 500]  # 訓練輪數

params_names = [
    "data_amount",
    "learning_rate",
    "num_filters",
    "dense_unit",
    "batch_size",
    "epochs",
    "accuracy"
]

X_train, X_test, y_train, y_test = get_processed_data(
    X=mfcc_matrix_list,
    y=data_class_label,
    num_classes=num_classes,
    mfcc_dim_1=mfcc_dim_1,
    mfcc_dim_2=mfcc_dim_2,
    channel=channel,
    test_size=test_size,
)

# 網格搜尋
folder = f".\\hyper_parameters_record\\"
if not os.path.isdir(folder):
    os.mkdir(folder)

record_file_name = f".\\hyper_parameters_record\\hyper_params_{mfcc_matrix_list.shape[0]}.csv"
if not os.path.exists(record_file_name):
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
                        "data_amount": mfcc_matrix_list.shape[0],
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

best_params["max_accuracy"] = max_accuracy
with open(f"best_params.json", "w") as json_file:
    json.dump(best_params, json_file)

# DISCORD -> 設定 -> 整合 -> Webhook -> 新 Webhook > -> 複製 Webhook 網址
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1287413088970346557/30gx7NdIfSxS1BRWk28IRkOHJeoET-ihIN_KAjYeXYkrpPeI0hBnE-68AHzhpTR4h3et"
requests.post(
    url=DISCORD_WEBHOOK_URL,
    data={"content": "cnn grid search method2 layer1 with fake data 超參數尋找已完成!"}
)