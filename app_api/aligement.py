import torch
from torchaudio.pipelines import MMS_FA as bundle
from typing import List
import IPython
import matplotlib.pyplot as plt
from pypinyin import pinyin, lazy_pinyin, Style
from pydub import AudioSegment
import librosa
import speech_recognition

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

def _score(spans):
    return sum(s.score * len(s) for s in spans) / sum(len(s) for s in spans)

def plot_alignments(waveform, token_spans, emission, transcript, sample_rate=bundle.sample_rate):
    ratio = waveform.size(1) / emission.size(1) / sample_rate

    fig, axes = plt.subplots(2, 1)
    axes[0].imshow(emission[0].detach().cpu().T, aspect="auto")
    axes[0].set_title("Emission")
    axes[0].set_xticks([])

    axes[1].specgram(waveform[0], Fs=sample_rate)
    for t_spans, chars in zip(token_spans, transcript):
        t0, t1 = t_spans[0].start, t_spans[-1].end
        axes[0].axvspan(t0 - 0.5, t1 - 0.5, facecolor="None", hatch="/", edgecolor="white")
        axes[1].axvspan(ratio * t0, ratio * t1, facecolor="None", hatch="/", edgecolor="white")
        axes[1].annotate(f"{_score(t_spans):.2f}", (ratio * t0, sample_rate * 0.51), annotation_clip=False)

        for span, char in zip(t_spans, chars):
            t0 = span.start * ratio
            axes[1].annotate(char, (t0, sample_rate * 0.55), annotation_clip=False)

    axes[1].set_xlabel("time [second]")
    fig.tight_layout()

def preview_word(waveform, spans, num_frames, transcript, sample_rate):
    ratio = waveform.size(1) / num_frames
    x0 = int(ratio * spans[0].start)
    x1 = int(ratio * spans[-1].end)
    #print(f"{transcript} ({_score(spans):.2f}): {x0 / sample_rate:.3f} - {x1 / sample_rate:.3f} sec")
    time_StarAndEnd = [ x0 / sample_rate, x1/sample_rate] # 回傳單個字的起始時間與結束時間
    segment = waveform[:, x0:x1]
    #return IPython.display.Audio(segment.numpy(), rate=sample_rate)
    return time_StarAndEnd

def text_recognize():
    torch.cuda.empty_cache()
    torch.cuda.memory_summary(device=None, abbreviated=False)
    raw_data_path = f".\\app_voice\\recorded.wav"
    r = speech_recognition.Recognizer()
    raw_data = speech_recognition.AudioFile(raw_data_path)
    with raw_data as source:
        audio = r.record(source)
    result = r.recognize_google(audio, language='zh-tw')

    sentence = result.lower().replace('》', '').replace('《', '').replace('%', '').replace('。', '').replace('?',
                                                                                                          '').replace(
        '【', '').replace('】', '').replace('-', '').replace('.', '').replace(',', '').replace('6', '六').replace('4',
                                                                                                                '四').replace(
        '2', '二').replace('9', '九').replace('8', '八').replace('5', '五').replace('3', '三').replace('0',
                                                                                                       '零').replace(
        '1', '一').replace('7', '七').replace(' ', '').replace('、', '')
    print(sentence)
    return sentence

    # audio = AudioSegment.from_file(raw_data_path)
    # audio.export(f".\\sentences\\{(sentence.lower())}.wav", format="wav")
    #
    # text_normalized = ' '.join(lazy_pinyin(sentence))  # 將文字轉為沒有音調的拼音，lazy_pinyin是陣列所以要再join成字串
    #
    # waveform, sample_rate = librosa.load(f".\\sentences\\{sentence}.wav")
    # waveform_tensor = torch.tensor(waveform).unsqueeze(0)
    #
    # transcript = text_normalized.split()
    # emission, token_spans = compute_alignments(waveform_tensor, transcript)
    # num_frames = emission.size(1)
    #
    # # plot_alignments(waveform, token_spans, emission, transcript)
    #
    # print("Raw Transcript: ", sentence)
    # print("Normalized Transcript: ", text_normalized)
    # IPython.display.Audio(waveform, rate=sample_rate)
    #
    # text_raw = sentence
    # word_start_end = []
    # pinyin_tone = pinyin(text_raw, style=Style.TONE3, heteronym=False)
    # for j in range(len(transcript)):  # len(transcript)
    #     timeStartEnd = preview_word(waveform_tensor, token_spans[j], num_frames, transcript[j], sample_rate)
    #     word_start_end.append([pinyin_tone[j][0], timeStartEnd[0], timeStartEnd[1]])
    #     print(word_start_end)
    #
    #     audio = AudioSegment.from_file(f".\\sentences\\{sentence}.wav")
    #     file_name = sentence
    # for k in range(len(word_start_end)):
    #     segment_audio = audio[word_start_end[k][1] * 1000: word_start_end[k][2] * 1000]
    #     segment_audio.export(f".\\data\\{file_name}-{k}_{word_start_end[k][0]}.wav", format="wav")
    # print('------------------------------------------')

