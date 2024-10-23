from flask import Flask, request, jsonify
import os
from aligement import text_recognize
from process import *
from tensorflow.keras.models import load_model
from process import  load_recorded
from glob import glob
import pandas as pd
import socket
app = Flask(__name__)

UPLOAD_FOLDER = f".\\app_voice\\"
if not os.path.isdir(UPLOAD_FOLDER):
    os.mkdir(UPLOAD_FOLDER)

hostname = socket.gethostname()
host_ip = socket.gethostbyname(hostname)
host_port = 5000

@app.route('/app_voice', methods=['POST'])
def upload_file():
    # if 'file' not in request.files:
    #     return jsonify({'error': 'No file part'}), 400
    #
    file = request.files['file']
    # if file.filename == '':
    #     return jsonify({'error': 'No selected file'}), 400

    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    sentence = text_recognize()

    result = {
        "message": sentence,
        "file_path": file_path
    }

    return jsonify(result), 200

@app.route('/get_analysis', methods=['GET'])
def getAnalysis():
    edu_pinyin_df = pd.read_csv(filepath_or_buffer="..\\cnn_method2\\tables\\edu_pinyin_label_table.csv")

    predict_pinyin_list, pinyin_list, sentence = model_predict()

    for i in range(len(pinyin_list)):
        if pinyin_list[i][-1] == "1":
            pinyin_list[i] = pinyin_list[i][:-1]
        elif not pinyin_list[i][-1].isdigit():
            pinyin_list[i] = pinyin_list[i] + "5"

    sentence_list = [word for word in sentence]

    bopomofo_list = list()

    for pinyin in pinyin_list:
        bopomofo = edu_pinyin_df.loc[edu_pinyin_df["pinyin"] == pinyin, "bopomofo"].values[0]
        bopomofo_list.append(bopomofo)

    predict_bopomofo_list = list()

    for pinyin in predict_pinyin_list:
        bopomofo = edu_pinyin_df.loc[edu_pinyin_df["pinyin"] == pinyin, "bopomofo"].values[0]
        predict_bopomofo_list.append(bopomofo)

    main_sentence = ""
    correct_info_list = list()
    for i in range(len(sentence_list)):
        if predict_pinyin_list[i] == pinyin_list[i]:
            main_sentence += sentence_list[i]
        else:
            main_sentence += predict_bopomofo_list[i]
            correct_info = [sentence_list[i], bopomofo_list[i], pinyin_list[i]]
            correct_info_list.append(correct_info)

    analysis = {
        "main_sentence": main_sentence,
        "correct_info_list": correct_info_list
    }

    return jsonify(analysis), 200

app.run(debug=True, host=host_ip, port=host_port)