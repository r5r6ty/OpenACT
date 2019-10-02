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
            FileStream fs = new FileStream(path + files[i], FileMode.Open);
            byte[] bt = new byte[fs.Length];
            fs.Read(bt, 0, bt.Length);
            fs.Close();

            WWUtils.Audio.WAV wav = new WWUtils.Audio.WAV(bt);
            Debug.Log(files[i] + wav);
            ac[i] = AudioClip.Create("testSound", wav.SampleCount, wav.ChannelCount, wav.Frequency, false);
            ac[i].SetData(wav.LeftChannel, 0);
            //Debug.Log(files[i] + ac[i].length + wav);


            //string a = "";
            //for (int i2 = 0; i2 < wav.LeftChannel.Length; i2++)
            //{
            //    a += wav.LeftChannel[i2].ToString() + "\n";
            //}

            //File.WriteAllText(@"D:\unityproject\OpenACT\Assets\StreamingAssets\1\Resource\wocao2.txt", a);
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
