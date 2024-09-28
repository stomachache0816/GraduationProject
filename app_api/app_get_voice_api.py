from flask import Flask, request, jsonify
import os

import torch
import torchaudio
from torchaudio.pipelines import MMS_FA as bundle
from typing import List
import IPython
import matplotlib.pyplot as plt
from pypinyin import pinyin, lazy_pinyin, Style

import whisper
import librosa
from opencc import OpenCC

app = Flask(__name__)

UPLOAD_FOLDER = f".\\app_voice\\"
if not os.path.isdir(UPLOAD_FOLDER):
    os.mkdir(UPLOAD_FOLDER)

host_ip = "192.168.1.111"
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

    result = {
        'message': 'File uploaded successfully',
        'file_path': file_path
    }

    return jsonify(result), 200


app.run(debug=True, host=host_ip, port=host_port)