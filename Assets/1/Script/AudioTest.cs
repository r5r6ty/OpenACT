using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class AudioTest : MonoBehaviour
{
    public string path;
    public string[] files;
    public AudioSource music;
    public AudioClip[] ac;
    public int position = 0;
    public int samplerate = 44100;
    public float frequency = 440;

    // Start is called before the first frame update
    void Start()
    {
        ac = new AudioClip[files.Length];

        music = gameObject.AddComponent<AudioSource>();
        music.playOnAwake = false;

        //ac = AudioClip.Create("MySinusoid", samplerate * 2, 1, samplerate, true, OnAudioRead, OnAudioSetPosition);
        //music.clip = ac;

        for (int i = 0; i < files.Length; i++)
        {
            byte[] bt = File.ReadAllBytes(path + files[i]);

            WWUtils.Audio.WAV wav = new WWUtils.Audio.WAV(bt);
            Debug.Log(files[i] + wav);
            ac[i] = AudioClip.Create("testSound", wav.SampleCount, wav.ChannelCount, wav.Frequency, false);
            if (wav.ChannelCount == 2 && wav.RightChannel != null)
            {
                // Unity 的 SetData 要左右声道交错存放
                float[] stereo = new float[wav.SampleCount * 2];
                for (int j = 0; j < wav.SampleCount; j++)
                {
                    stereo[j * 2] = wav.LeftChannel[j];
                    stereo[j * 2 + 1] = wav.RightChannel[j];
                }
                ac[i].SetData(stereo, 0);
            }
            else
            {
                ac[i].SetData(wav.LeftChannel, 0);
            }
        }

        //music.clip = ac;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnGUI()
    {
        for (int i = 0; i < files.Length; i++)
        {
            if (GUILayout.Button(files[i]))
            {
                music.clip = ac[i];
                music.Play();
            }
        }
    }

    void OnAudioRead(float[] data)
    {
        int count = 0;
        while (count < data.Length)
        {
            data[count] = Mathf.Sin(2 * Mathf.PI * frequency * position / samplerate);
            position++;
            count++;
        }
    }

    void OnAudioSetPosition(int newPosition)
    {
        position = newPosition;
    }
}
