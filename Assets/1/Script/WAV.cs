using UnityEngine;
using System.Collections;
using System.IO;

namespace WWUtils.Audio
{
    public class WAV
    {

        // convert two bytes to one float in the range -1 to 1
        static float bytesToFloat(byte firstByte, byte secondByte)
        {
            // convert two bytes to one short (little endian)
            short s = (short)((secondByte << 8) | firstByte);
            // convert to range from -1 to (just below) 1
            return s / 32768.0F;
        }

        static float byteToFloat(byte _Byte)
        {
            //short s = (short)((_Byte << 8));
            //Debug.Log(s / 32768.0F + "," + _Byte + "," + s);
            //return s / 32768.0F;

            char s = (char)((_Byte));
            //Debug.Log(s / (32768.0F / 256.0F) + "," + _Byte + "," + s);
            //float s2 = s / (32768.0F / 256.0F);
            //if (s2 > 1)
            //    return -(2 - s2);
            //else
            //    return s2;

            return 1 - (s / (32768.0F / 256.0F));
        }

        static int bytesToInt(byte[] bytes, int offset = 0)
        {
            int value = 0;
            for (int i = 0; i < 4; i++)
            {
                value |= ((int)bytes[offset + i]) << (i * 8);
            }
            return value;
        }

        private static byte[] GetBytes(string filename)
        {
            return File.ReadAllBytes(filename);
        }
        // properties
        public float[] LeftChannel { get; internal set; }
        public float[] RightChannel { get; internal set; }
        public int ChannelCount { get; internal set; }
        public int SampleCount { get; internal set; }
        public int Frequency { get; internal set; }

        // Returns left and right double arrays. 'right' will be null if sound is mono.
        public WAV(string filename) :
            this(GetBytes(filename))
        { }

        public WAV(byte[] wav)
        {



            int pos = 0;
            // fmt
            while (!(wav[pos] == 102 && wav[pos + 1] == 109 && wav[pos + 2] == 116))
            {
                pos++;
            }
            //Debug.Log(pos);

            // Determine if mono or stereo
            ChannelCount = wav[pos + 10];     // Forget byte 23 as 99.999% of WAVs are 1 or 2 channels
            //Debug.Log(wav[20]);
            //Debug.Log(wav[21]);
            //Debug.Log(wav[22]);
            //Debug.Log(wav[23]);

            // Get the frequency
            Frequency = bytesToInt(wav, pos + 12);


            int size = wav[pos + 20];
            int bbbit = wav[pos + 22];

            //Debug.Log("Frequency=" + Frequency);
            //Debug.Log("ByteRate=" + bytesToInt(wav, pos + 16));
            //Debug.Log("BlockAlign=" + size);
            //Debug.Log("BitsPerSample=" + bbbit);

            // Get past all the other sub chunks to get to the data subchunk:
            //pos = 12;   // First Subchunk ID from 12 to 16

            // Keep iterating until we find the data chunk (i.e. 64 61 74 61 ...... (i.e. 100 97 116 97 in decimal))
            // data
            while (!(wav[pos] == 100 && wav[pos + 1] == 97 && wav[pos + 2] == 116 && wav[pos + 3] == 97))
            {
                pos += 4;
                int chunkSize = wav[pos] + wav[pos + 1] * 256 + wav[pos + 2] * 65536 + wav[pos + 3] * 16777216;
                //Debug.Log(chunkSize);
                pos += 4 + chunkSize;
            }
            pos += 8;

            // Pos is now positioned to start of actual sound data.
            //Debug.Log(wav.Length);
            //Debug.Log(pos);
            //SampleCount = (wav.Length - pos + 1);     // 2 bytes per sample (16 bit sound mono)
 
            SampleCount = bytesToInt(wav, pos - 4) / size;
            //Debug.Log(pos - 4);
            //Debug.Log(SampleCount);
            //Debug.Log(pos - 4);
            if (ChannelCount == 2) SampleCount /= 2;        // 4 bytes per sample (16 bit stereo)

            // Allocate memory (right will be null if only mono sound)
            LeftChannel = new float[SampleCount];
            if (ChannelCount == 2) RightChannel = new float[SampleCount];
            else RightChannel = null;

            // Write to double array/s:
            int i = 0;
            if (bbbit == 16)
            {
                while (i < SampleCount)
                {
                    LeftChannel[i] = bytesToFloat(wav[pos], wav[pos + 1]);
                    pos += 2;
                    if (ChannelCount == 2)
                    {
                        RightChannel[i] = bytesToFloat(wav[pos], wav[pos + 1]);
                        pos += 2;
                    }
                    i++;
                }
            }
            else
            {
                while (i < SampleCount)
                {
                    LeftChannel[i] = byteToFloat(wav[pos]);
                    pos += 1;
                    if (ChannelCount == 2)
                    {
                        RightChannel[i] = byteToFloat(wav[pos]);
                        pos += 1;
                    }
                    i++;
                }
            }



            if (ChannelCount == 0)
            {
                Debug.Log("ChannelCount=0");
                ChannelCount = 1;
            }

            if (Frequency == 0)
            {
                Debug.Log("Frequency=0");
                Frequency = 44100;
            }
        }

        public override string ToString()
        {
            return string.Format("[WAV: LeftChannel={0}, RightChannel={1}, ChannelCount={2}, SampleCount={3}, Frequency={4}]", LeftChannel.Length, RightChannel, ChannelCount, SampleCount, Frequency);
        }
    }

}