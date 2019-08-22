using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class AudioTest : MonoBehaviour
{
    public string path;
    public AudioSource music;
    public AudioClip ac;
    public int position = 0;
    public int samplerate = 44100;
    public float frequency = 440;

    // Start is called before the first frame update
    void Start()
    {
        music = gameObject.AddComponent<AudioSource>();
        music.playOnAwake = false;

        //ac = AudioClip.Create("MySinusoid", samplerate * 2, 1, samplerate, true, OnAudioRead, OnAudioSetPosition);
        //music.clip = ac;

        FileStream fs = new FileStream(path, FileMode.Open);
        byte[] bt = new byte[fs.Length];
        fs.Read(bt, 0, bt.Length);
        fs.Close();

        WWUtils.Audio.WAV wav = new WWUtils.Audio.WAV(bt);
        Debug.Log(wav);
        ac = AudioClip.Create("testSound", wav.SampleCount, wav.ChannelCount, wav.Frequency, false);
        ac.SetData(wav.LeftChannel, 0);

        string a = "";
        for( int i = 0; i < wav.LeftChannel.Length; i++)
        {
            a += wav.LeftChannel[i].ToString() + "\n";
        }

        File.WriteAllText(@"D:\unityproject\OpenACT\Assets\StreamingAssets\1\Resource\wocao2.txt", a);

        music.clip = ac;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnGUI()
    {
        if (GUILayout.Button("play"))
        {
            music.Play();
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
