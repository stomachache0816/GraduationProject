from flask import Flask, request, jsonify
import os

app = Flask(__name__)

UPLOAD_FOLDER = f".\\app_voice\\"
if not os.path.isdir(UPLOAD_FOLDER):
    os.mkdir(UPLOAD_FOLDER)

host_ip = "127.0.0.1"
host_port = 5000

@app.route('/voice', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    return jsonify({'message': 'File uploaded successfully', 'file_path': file_path}), 200


app.run(debug=True, host=host_ip, port=host_port)