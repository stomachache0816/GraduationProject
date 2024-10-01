from tensorflow.keras.models import load_model
import torch
from torchaudio.pipelines import MMS_FA as bundle
from typing import List
import IPython
import matplotlib.pyplot as plt
from pypinyin import pinyin, lazy_pinyin, Style
from pydub import AudioSegment
import librosa
import speech_recognition
from aligement import text_recognize
from glob import glob
import os
import numpy as np
import librosa
from sklearn.preprocessing import StandardScaler
from tqdm import tqdm

def compute_alignments(waveform: torch.Tensor, transcript: List[str]):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = bundle.get_model()
    model.to(device)
    tokenizer = bundle.get_tokenizer()
    aligner = bundle.get_aligner()
    with torch.inference_mode():
        emission, _ = model(waveform.to(device))
        token_spans = aligner(emission[0], tokenizer(transcript))
    return emission, token_spans

def preview_word(waveform, spans, num_frames, transcript, sample_rate):
    ratio = waveform.size(1) / num_frames
    x0 = int(ratio * spans[0].start)
    x1 = int(ratio * spans[-1].end)
    #print(f"{transcript} ({_score(spans):.2f}): {x0 / sample_rate:.3f} - {x1 / sample_rate:.3f} sec")
    time_StarAndEnd = [ x0 / sample_rate, x1/sample_rate] # 回傳單個字的起始時間與結束時間
    segment = waveform[:, x0:x1]
    #return IPython.display.Audio(segment.numpy(), rate=sample_rate)
    return time_StarAndEnd

def load_recorded():
    sentence = text_recognize()

    sentence_path_list = glob(pathname=f".\\sentences\\*.wav")
    counter = len(sentence_path_list)

    raw_data_path = f".\\app_voice\\recorded.wav"
    audio = AudioSegment.from_file(raw_data_path)

    sentence_path_name = f".\\sentences\\{counter}_{(sentence.lower())}.wav"
    audio.export(sentence_path_name, format="wav")

    text_normalized = ' '.join(lazy_pinyin(sentence))  # 將文字轉為沒有音調的拼音，lazy_pinyin是陣列所以要再join成字串

    waveform, sample_rate = librosa.load(sentence_path_name)
    waveform_tensor = torch.tensor(waveform).unsqueeze(0)

    transcript = text_normalized.split()
    emission, token_spans = compute_alignments(waveform_tensor, transcript)
    num_frames = emission.size(1)

    # plot_alignments(waveform, token_spans, emission, transcript)

    print("Raw Transcript: ", sentence)
    print("Normalized Transcript: ", text_normalized)
    IPython.display.Audio(waveform, rate=sample_rate)

    text_raw = sentence
    word_start_end = []
    pinyin_tone = pinyin(text_raw, style=Style.TONE3, heteronym=False)
    for j in range(len(transcript)):  # len(transcript)
        timeStartEnd = preview_word(waveform_tensor, token_spans[j], num_frames, transcript[j], sample_rate)
        word_start_end.append([pinyin_tone[j][0], timeStartEnd[0], timeStartEnd[1]])
        print(word_start_end)

        audio = AudioSegment.from_file(sentence_path_name)
        file_name = sentence

    data_dir_path = sentence_path_name.replace("\\sentences\\", "\\data\\").replace(".wav", "")
    if not os.path.exists(data_dir_path):
        os.makedirs(data_dir_path)

    for k in range(len(word_start_end)):
        segment_audio = audio[word_start_end[k][1] * 1000: word_start_end[k][2] * 1000]
        segment_audio.export(f"{data_dir_path}\\{file_name}-{k}_{word_start_end[k][0]}.wav", format="wav")
        # print(f"{data_dir_path}\\{file_name}-{k}_{word_start_end[k][0]}.wav")
    print('------------------------------------------')

    return data_dir_path


def get_mfcc(file_path, n_mfcc, max_pad_len, n_fft=2048, sr=22050, fmax=None, n_mels=128):
    # 讀取音檔，轉為單聲道
    audio, sample_rate = librosa.load(file_path, mono=True, sr=sr)

    # 確保 n_fft 小於或等於輸入信號的長度
    n_fft = min(n_fft, len(audio))

    # 計算梅爾頻率倒譜係數（MFCC）
    mfccs = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=n_mfcc, n_fft=n_fft, n_mels=n_mels, fmax=fmax)

    # 計算填充或截斷的長度
    pad_width = max_pad_len - mfccs.shape[1]
    if pad_width < 0:
        # 截斷
        mfccs = mfccs[:, :max_pad_len]
    else:
        # 填充
        mfccs = np.pad(mfccs, pad_width=((0, 0), (0, pad_width)), mode='constant')

    return mfccs


def model_predict():
    data_dir_path = load_recorded()
    wav_file_path_list = glob(f"{data_dir_path}\\*.wav")

    npy_file_path_list = list()
    for wav_file_path in wav_file_path_list:
        pinyin = wav_file_path[wav_file_path.find("_", wav_file_path.find("-")) + 1: wav_file_path.find(".wav")]
        npy_file_path = ""
        if pinyin[-1] == "1":
            npy_file_path = wav_file_path.replace(f"{pinyin}.wav", f"{pinyin.replace('1', '')}.npy")
        elif pinyin[-1] not in ["2", "3", "4"]:
            npy_file_path = wav_file_path.replace(f"{pinyin}.wav", f"{pinyin}5.npy")
        else:
            npy_file_path = wav_file_path.replace(".wav", ".npy")
        npy_file_path_list.append(npy_file_path)
        n_mfcc: int = 13  # row
        max_pad_len: int = 44  # column
        mfcc = get_mfcc(wav_file_path, n_mfcc, max_pad_len, n_fft=2048, sr=22050, fmax=None, n_mels=128)

        np.save(file=npy_file_path, arr=mfcc)

    mfcc_matrix_list = list()

    for npy_file_path in tqdm(npy_file_path_list):
        mfcc_matrix = np.load(file=npy_file_path)
        mfcc_matrix_list.append(mfcc_matrix)

    mfcc_matrix_list = np.array(mfcc_matrix_list)

    scaler = StandardScaler()
    scaler.fit(
        mfcc_matrix_list.reshape(
            (mfcc_matrix_list.shape[0] * mfcc_matrix_list.shape[1], mfcc_matrix_list.shape[2])
        )
    )

    mfcc_matrix_list_scaled = []
    for mfcc in mfcc_matrix_list:
        mfcc_matrix_list_scaled.append(scaler.transform(mfcc))

    mfcc_matrix_list_scaled = np.array(mfcc_matrix_list_scaled)

    print(mfcc_matrix_list_scaled.shape)


    # model = load_model(filepath=f"..\\cnn_method1\\cnn_model.h5")
    # predictions = model.predict()
