import pandas as pd
from glob import glob
from tqdm import tqdm
import json
from model_training_process import *
import requests
import matplotlib.pyplot as plt
import os
import csv

class_df = pd.read_csv(filepath_or_buffer="..\\..\\..\\cnn_method2\\tables\\corrected_class_df_pinyin_label_table.csv")
class_df['class_label_index'] = class_df.groupby('class_label').cumcount()
npy_file_path_list = glob(pathname="..\\..\\..\\data\\*EduVer\\*.npy", recursive=True)

selected_npy_file_path_list = list()
for npy_file_path in npy_file_path_list:
    pinyin = npy_file_path.split("_")[1]
    pinyin_non_accent = pinyin[:-1] if pinyin[-1].isdigit() else pinyin
    if pinyin_non_accent in list(class_df["pinyin"]):
        selected_npy_file_path_list.append(npy_file_path)

dic = dict()

for i in range(len(class_df.groupby("class_label").count().index)):
    dic[f"class_{i}_mfcc_matrix_list"] = list()
    dic[f"class_{i}_accent_label_index_list"] = list()

for npy_file_path in tqdm(selected_npy_file_path_list):
    pinyin = npy_file_path.split("_")[1]
    pinyin_non_accent = pinyin[:-1] if pinyin[-1].isdigit() else pinyin
    accent_label = int(pinyin[-1] if pinyin[-1].isdigit() else 1)
    class_label = class_df.loc[class_df["pinyin"] == pinyin_non_accent, "class_label"].values[0]
    # class_label_index = class_df.loc[class_df["pinyin"] == pinyin_non_accent, "class_label_index"].values[0]
    # print(f"{pinyin_non_accent}, {class_label}, {class_label_index}")

    mfcc_matrix = np.load(npy_file_path)
    dic[f"class_{class_label}_mfcc_matrix_list"].append(mfcc_matrix)
    dic[f"class_{class_label}_accent_label_index_list"].append(accent_label)

for i in range(len(class_df.groupby("class_label").count().index)):
    dic[f"class_{i}_mfcc_matrix_list"] = np.array(dic[f"class_{i}_mfcc_matrix_list"])
    dic[f"class_{i}_accent_label_index_list"] = np.array(dic[f"class_{i}_accent_label_index_list"])

for i in range(len(class_df.groupby("class_label").count().index)):
    print(f"class_{i}_mfcc_matrix_list.shape: {dic[f'class_{i}_mfcc_matrix_list'].shape}")
    print(f"class_{i}_accent_label_index_list.shape: {dic[f'class_{i}_accent_label_index_list'].shape}")

channel = 1
verbose = 2
num_classes = len(class_df.index)
test_size = 0.2

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

# 網格搜尋
folder_path = f".\\hyper_parameters_record\\"
if not os.path.isdir(folder_path):
    os.mkdir(folder_path)

folder_path = f".\\best_parameters_record\\"
if not os.path.isdir(folder_path):
    os.mkdir(folder_path)

model_train_info_list = list()
model_list = list()

for i in tqdm(range(len(class_df.groupby("class_label").count().index))):
    record_file_name = f".\\hyper_parameters_record\\hyper_params_class_{i}.csv"
    if not os.path.exists(record_file_name):
        with open(file=record_file_name, mode="a", newline="") as file:
            writer = csv.DictWriter(file, fieldnames=params_names)
            writer.writeheader()

    max_accuracy: float = 0
    best_params: dict = {}

    for learning_rate in learning_rate_range:
        for num_filters in num_filters_range:
            for dense_unit in dense_units_range:
                for batch_size in batch_size_range:
                    for epochs in epochs_range:
                        X = dic[f"class_{i}_mfcc_matrix_list"]
                        y = dic[f"class_{i}_accent_label_index_list"]

                        mfcc_dim_1 = X.shape[1]
                        mfcc_dim_2 = X.shape[2]
                        num_classes = len(class_df.index)

                        X_train, X_test, y_train, y_test = get_processed_data(
                            X=X,
                            y=y,
                            num_classes=num_classes,
                            mfcc_dim_1=mfcc_dim_1,
                            mfcc_dim_2=mfcc_dim_2,
                            channel=channel,
                            test_size=test_size,
                        )

                        model = get_cnn_model(
                            input_shape=(mfcc_dim_1, mfcc_dim_2, channel),
                            num_classes=num_classes,
                            learning_rate=learning_rate,
                            num_filters=num_filters,
                            dense_units=dense_unit
                        )

                        model_train_info = model.fit(
                            X_train,
                            y_train,
                            batch_size=batch_size,
                            epochs=epochs,
                            verbose=verbose,
                            validation_data=(X_test, y_test)
                        )

                        val_accuracies = model_train_info.history['val_accuracy']
                        current_max_accuracy = max(val_accuracies)

                        parameters = {
                            "data_amount": X.shape[0],
                            "learning_rate": learning_rate,
                            "num_filters": num_filters,
                            "dense_unit": dense_unit,
                            "batch_size": batch_size,
                            "epochs": epochs,
                            "accuracy": current_max_accuracy
                        }

                        if current_max_accuracy > max_accuracy:
                            max_accuracy = current_max_accuracy
                            best_params = parameters

                        with open(file=record_file_name, mode="a", newline="") as file:
                            writer = csv.DictWriter(file, fieldnames=parameters.keys())
                            writer.writerow(parameters)

    with open(f".\\best_parameters_record\\best_parameters_class{i}.json", "w") as json_file:
        json.dump(best_params, json_file)

# DISCORD -> 設定 -> 整合 -> Webhook -> 新 Webhook > -> 複製 Webhook 網址
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1287413088970346557/30gx7NdIfSxS1BRWk28IRkOHJeoET-ihIN_KAjYeXYkrpPeI0hBnE-68AHzhpTR4h3et"
requests.post(
    url=DISCORD_WEBHOOK_URL,
    data={"content": "cnn grid search method2 layer3 with fake data 超參數尋找已完成!"}
)