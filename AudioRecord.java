package cn.hugeox.poke.record;

import android.content.Context;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Environment;
import android.util.Log;

import org.cocos2dx.lib.Cocos2dxActivity;

import java.io.File;
import java.io.IOException;

/**
 * Created by guange on 13/12/2016.
 */
public class AudioRecord {
    private static final String TAG = AudioRecord.class.getName();
    private MediaRecorder mRecorder = null;
    private MediaPlayer mPlayer = null;
    private String audioFilePath = null;


    private static AudioRecord audioRecord = null;
    public static AudioRecord getInstance(){
        if(audioRecord==null){
            audioRecord = new AudioRecord();
        }
        return audioRecord;
    }


    private AudioRecord(){
    }


    public void startRecording() {

        if(mRecorder!=null){
            Log.e(TAG, "startRecording: 正在录音中");
            return ;
        }

        try {
            String fileName = ""+System.currentTimeMillis();
            new File(this.getAmrFilePath(fileName)).deleteOnExit();

            mRecorder = new MediaRecorder();
            mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);

            mRecorder.setOutputFormat(MediaRecorder.OutputFormat.AMR_NB);
            mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
            mRecorder.setAudioChannels(1);

            // 设置麦克风
//            mRecorder.setOutputFormat(MediaRecorder.OutputFormat.DEFAULT);// 设置输出文件格式
//            mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.DEFAULT);// 设置编码格式
            mRecorder.setOutputFile(this.getAmrFilePath(fileName));// 使用绝对路径进行保存文件
            mRecorder.prepare();
            mRecorder.start();

            audioFilePath = this.getAmrFilePath(fileName);
        } catch (IOException e) {
            Log.e(TAG, "prepare() failed");
        }

    }

    public String stopRecording() {
        if(mRecorder!=null){
            mRecorder.stop();
            mRecorder.release();
            mRecorder = null;
            return this.audioFilePath;
        }
        return "";
    }


    public void startPlaying(String fileName) {

        Log.d(TAG, "startPlaying: "+fileName);
        try {
            mPlayer = new MediaPlayer();
            mPlayer.setDataSource(fileName);//获取绝对路径来播放音频
            mPlayer.prepare();
            mPlayer.start();
            mPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
                @Override
                public boolean onError(MediaPlayer mediaPlayer, int i, int i1) {
                    stopPlaying();
                    return false;
                }
            });
            mPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mp) {
                    // TODO Auto-generated method stub
                    stopPlaying();
                }
            });
        } catch (IOException e) {
            Log.e(TAG, "prepare() failed");
        }
    }
    public void stopPlaying() {
        if(mPlayer!=null){
            mPlayer.stop();
            mPlayer.release();
            mPlayer = null;
        }
    }

    public String getAmrFilePath(String fileName) {
        return Cocos2dxActivity
                .getContext()
                .getExternalFilesDir("audios")
                .getAbsolutePath() + "/"+fileName+".amr";
    }
}

