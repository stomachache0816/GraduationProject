from flask import Flask, request, jsonify
import os
from aligement import text_recognize
from tensorflow.keras.models import load_model
from process import  load_recorded
from glob import glob
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

    sentence = text_recognize()

    result = {
        "message": sentence,
        "file_path": file_path
    }

    return jsonify(result), 200

# def model_predict():
#     load_recorded()
#     counter = len(glob(".\\data\\"))
#     wav_file_path_list = glob(f"")
#
#     model = load_model(filepath=f"..\\cnn_method1\\cnn_model.h5")
#     predictions = model.predict()




app.run(debug=True, host=host_ip, port=host_port)