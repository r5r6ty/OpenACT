﻿using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Networking;

public class GameLoader : MonoBehaviour
{
    public GameObject init;
    public string folder;

    // 静态使路径只有一个
    static string luapath;

    public string[] scripts;
    public Object[] prefabs;

    int count = 0;
    int total = 0;

    static public string Getluapath()
    {
        return luapath;
    }

    void Awake()
    {
#if UNITY_EDITOR_WIN || UNITY_STANDALONE_WIN
        luapath = Application.dataPath + "/" + folder + "/";
#endif

        foreach (Object s in prefabs)
        {
            ObjectManager.Instance.SetO(s.name, s);
        }

        total = scripts.Length;
        foreach (string s in scripts)
        {
            StartCoroutine(ReadData(luapath + s + ".lua"));
        }
    }

    IEnumerator ReadData(string path)
    {
        UnityWebRequest www = UnityWebRequest.Get(path);
        yield return www.SendWebRequest();
        while (www.isDone == false)
        {
            yield return new WaitForEndOfFrame();
        }
        yield return new WaitForSeconds(0.5f);
        string scripts = www.downloadHandler.text;
        string methodName = path.Replace(".lua", "");
        methodName = methodName.Substring(methodName.LastIndexOf(@"/") + 1); // 获得名称
        print(methodName);
        LuaManager.Instance.SetScripts(methodName, scripts); // 下面有介绍

        count++;

        if (count >= total)
        {
            init.SetActive(true);
            //testStart();
            Destroy(gameObject);
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        //Debug.Log("a");
        //print(Base64Decode("AAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQALAAEAAQABAAEAAQABAAMABAAFAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEACQABAAEAAQABAAEAAQADAAUABQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAkAAQABAAEAAQABAAEABAADAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQAJAAEAAQABAAEAAQABAAMAAwABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEACQAJAAIAAQABAAEAAQADAAQAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAsACQACAAIAAgABAAEABAADAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQAKAAkAAQACAAEAAQABAAMABQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEACgABAAEAAQAFAAUAAwAEAAQAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQAAAAAAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAIAAgABAAEAAQABAAIAAQABAAEAAQABAAQABQABAAEAAQAFAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAAABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQACAAEAAQABAAEAAgABAAEAAQABAAEAAQADAAMAAQABAAEAAwABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAAAAQABAAEAAQABAAEAAQABAAEAAQACAAIAAQABAAEAAQABAAIAAQABAAEAAQABAAEAAQABAAEAAQAEAAEAAQADAAMAAQABAAEAAQABAAEAAQACAAEAAQABAAEAAQABAAEAAQAAAAEAAQABAAEAAQABAAEAAQACAAIAAgACAAEAAgABAAEAAQACAAEAAQACAAEAAQABAAsAAQABAAEABAAFAAQAAwABAAIAAQABAAEAAQABAAEAAgACAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAgABAAEAAgACAAIAAQABAAEAAQACAAIAAgABAAEAAQALAAEAAQABAAQABQABAAEAAgABAAIAAQABAAEAAgACAAEAAgABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAMAAwABAAEAAgABAAEAAQABAAEAAgABAAEAAQABAAsACQABAAEAAQADAAEAAQABAAIAAQACAAIAAgABAAIAAQACAAIAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAkACQAFAAEAAQABAAEAAQABAAEAAQACAAEAAQABAAEAAQALAAEAAQABAAEABQABAAEAAQABAAEAAQABAAEAAQACAAIAAQACAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEACwAKAAMABQABAAEAAQABAAEAAQABAAEAAgABAAEAAQABAAEACQABAAEAAQADAAQAAQABAAEAAQABAAEAAQABAAEAAQACAAEAAQACAAIAAQABAAEAAQABAAEAAQABAAEAAQABAAkACwAEAAEAAQABAAEAAQABAAEAAgACAAIAAQABAAEAAQABAAkAAQABAAEABQAEAAMAAQABAAEAAQABAAEAAQABAAIAAgABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAIAAgABAAoABQABAAEAAQABAAEAAQACAAEAAQABAAEAAQABAAEAAQAKAAsAAQABAAQAAQABAAEAAQABAAEAAQABAAEAAQACAAEAAQABAAIAAQABAAEAAQABAAEAAQABAAEAAgABAAIAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAgABAAEAAQABAAEAAQAKAAkAAQADAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQACAAEAAQABAAEAAQABAAEAAQACAAEAAQACAAIAAQABAAEAAQABAAEAAQABAAEAAQACAAIAAQABAAEAAQABAAEAAQAJAAEAAwABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAgABAAEAAQABAAEAAQABAAEAAQACAAEAAQACAAEAAQABAAEAAQABAAEACQABAAEAAQABAAEAAQABAAEAAQABAAEACgABAAMAAQABAAEAAQABAAEAAQALAAsACwABAAEAAQABAAIAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAkAAQABAAEAAQABAAEAAQABAAEAAQABAAsACgADAAsACgALAAkACQALAAkACwALAAsAAQABAAEAAQABAAIAAgABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAkACQAKAAkACgALAAEAAQABAAEAAQABAAEAAQABAAEAAwABAAEAAQABAAEAAQABAAsACgALAAsACQAKAAoACwALAAkACQAJAAsACwABAAEAAQABAAEAAQADAAMAAwAFAAEAAQAJAAkACQAJAAsACQABAAEAAQABAAEAAQABAAEAAQABAAMAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAwAFAAUAAQABAAEAAQAJAAoACgAKAAEAAQABAAEAAQABAAEAAQABAAEAAQADAAEAAQABAAEAAQAFAAQABAAFAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAUAAwADAAEAAQABAAEAAQAJAAoAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAwABAAEAAQABAAEABAAEAAUABQADAAMAAQABAAEAAQACAAIAAgABAAEAAQABAAEAAQABAAEAAQADAAUAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAMAAQABAAEAAQADAAUABQAFAAUAAQABAAEAAQABAAEAAgABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQADAAQAAQABAAUABQAFAAQAAwAFAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAgACAAIAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAwAFAAQAAwADAAUAAwAEAAQABAAEAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAIAAQABAAIAAQABAAEAAQABAAEAAQABAAEAAQABAAMAAwAEAAQABQAEAAQAAwADAAUABQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQADAAMAAwAFAAMAAwAFAAQABAADAAMAAQABAAEAAQABAAEAAQABAAEAAQABAAAAAQABAAEAAQABAAEAAQABAAEAAQACAAIAAQACAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAwADAAMABAADAAQABAAEAAQABAADAAMABQAFAAQABAABAAEAAQADAAQAAQAAAAEAAQABAAEAAQABAAEAAQABAAIAAQACAAEAAQABAAEAAQABAAEAAQAFAAMAAQABAAEAAQADAAMAAwADAAMAAwAFAAUAAwAFAAMABAADAAUABAADAAUABAAEAAUAAwAEAAQAAAAAAAEAAQABAAEAAQABAAEAAQABAAEAAQADAAUAAwAFAAMAAwAEAAMAAwAEAAUAAwADAAMAAwADAAUABQAEAAMABQAEAAMAAwAFAAMABAAEAAQABQAEAAUABQADAAMABQAFAAAAAAABAAEAAQABAAEAAQABAAEABAAEAAMAAwABAAEAAQABAAEAAQABAAEAAwADAAMAAQADAAMABQADAAMABAAEAAUABQAEAAMAAwAEAAMABAAEAAUABQAEAAQAAwADAAQABAAAAAAAAQABAAEAAQABAAEAAQADAAMAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAMABAADAAMABQAEAAQABQAEAAQAAwADAAMABQADAAUABAADAAMABQAFAAUAAAAAAAAAAAAAAAAAAAAAAAUABQAEAAUABQAEAAEAAQABAAEAAQACAAEAAQABAAEAAQABAAEAAQADAAQABQADAAMAAwAFAAQABAADAAQABQAFAAMABAAEAAQABQAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAEAAQABAAEAAQACAAIAAgABAAEAAgABAAMAAwADAAUAAwADAAUAAwADAAMABQAEAAMABQAEAAMAAwADAAMABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAIAAgACAAIAAQADAAUAAwAEAAQABQADAAMAAwADAAQABQADAAUABAAFAAUABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQACAAEABAAEAAMAAwADAAQAAwAEAAMABQADAAUABQAFAAUABAAEAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAEAAQABAAEAAQACAAIAAQABAAEAAQABAAUABQADAAUABAADAAMABAADAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAABQAFAAQABQAFAAEAAQABAAEAAQABAAEAAQACAAIAAQABAAEAAQAEAAQAAwAEAAMAAwADAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAQABQAFAAMABQADAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEABAAEAAQABQADAAMAAwAFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFAAUABQAFAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAMABQAEAAUABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="));
        //print(Base64Decode("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIQAAAAAAIgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACIAAAAmACEAAAAmACMAIgAAACIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIwAiAAAAAAAjACEAMQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACEAAAAhACIAIgAAACUAIgAhACMAIwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMgAAACYAJwAiACMAAAAAACMAIwAAACIAIgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIgAAAC0AIwAAACIAIwAiAAAAAAAhACEAIwAjACIAAAAAACMAAAAAAMIAwgDCAMIAwgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACEAAAAhAAAAIQAhACYAIgAAAAAALQAiACMAAAAAAAAAAAAhAC0AIgAmAAAAAAAAAAAAAAAeAB4AHgAeAB4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACIAJgAjADIAAAAtAAAAJgAjACEAIwAjAAAAAAAnAAAAIgAAAAAAAAAAAAAAIQAjACYAAAAjAAAAAAAAACEAAAAhACMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAjACYAIgAAAAAALQAAACIAIQAjACEAIwAhACIAAAAAAAAAAAAAAAAAAAAAAAAAIgAAAAAAIwAiAAAAAAAjAAAAAAAAAAAAAAAiACMAAAAAAAAAAAAAAAAAAAAAAAAAAAAyACEAAAAiACMAIgAtACEAAAAhAC0AAAAiACEAIgAiAAAAJgAAAAAAIwAAAAAAMQAAAAAAAAAhAC0AIwAhAAAAAAAmAAAAAAAjACMAAAAiACEAAAAAAAAAAAAAAAAAAAAAACIAAAAhAAAAIQAhACIAIgAiACEAIQAAACEAAAAiACIAMQAAAAAAAAAAACEAKgAAAAAAJwAAAAAAMQAAACEAIQAmACIAAAAhAAAAAAAiACEAAAAjAAAAAAAAAAAAIwAjAAAAIwAAACMAIQAtACIAIQAiACEAIQAAACEAIQAhACoAIQAjAAAAAAAAAAAAAAAAACEAAAAAAAAAKgAjACEAAAAAACMAIQAAACkAIgAAACYAAAAiAAAAIwAAAAAAAAAAAAAAIQAAACYAIQAjACMAIgAiACIAIQAhACEAAAAnAEcAAAAjACEAJwAAAAAAMgAAAAAAAAAnAAAAAAAhACMAIgAAACEAAAAAACIAIgAmAAAAAAAAAAAAIQAjAAAAIwAAAAAAAAAAACkAIQAhACEAIQAhAAAAAAAhAAAAIQAAAAAAAAAAACMAIQAjAAAAAAAAAAAAAAAAAAAAAAAAAAAAKgAiACEAJAAiACIAIgAAACEAAAAiACEAIgAAACEAIQAAACMAAAAAAAAAIwAAAC0AIgAiAAAAAAAAACEAAAAAAAAAAAAAAAAAAAAjACEAswAAADMAAAAAAC0AAAAAADEAAAAiACIAIwAkAAAAAAAkAAAAIgAjACMAAAAjAAAAJgAAACIAAAAjAAAAAAAjAAAAIQAAACIAKAA1AAAAAAA0AAAAIwAjACcAYQBiACMAIQAiALMAAAAAAAAAAAAoAAAAAAAAAAAAIgAjACQAAAAAACQAAAAkACQAAAAjAAAAJgAhACEAAAAAAAAAAAAAAAAAAAAiACYAIQAiAAAACAEJAQoBAAAhACEAIwAjACIAIQAhAAAAIgCzAAAAAAAAAAAAJgAAAEcAAAA2AAAAIwAkAAAAAAAAAPQAJAAkACMAIwAAACEAAAAtAAAAIQAAACMAAAAAACIAIQAAAAAAIQAjAAAAAAAlACIAIgAAAAAAIgAhAAAAAAAAAAAAswAAAAAAAAAAAAAAAAAAAAAAAAAjACQAAAAAAAAAAAAEAS0AAAAiACIAAAAAACIAAAAAACIALQAAAAAAJgAAAAAAIwAAACEAIgAAADQAIQAjACEAAAAAAAAAAAAAAAAAIgAAALMAAAAAAC0AAAAAAAAAAAAAAAAAJwAAAAAAAAAAAAAA8QDyAPMAJAAjACYAJgAiACEAJgAyAAAAIQAAAAAAAAAjACIAIQAmACMAAAAnACMAIwAAAAAAAAAAAAAARwAjACMAKQCzAAAAAABhAGIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEBAgEDAXUAAAAjAAAAAAAAACMALQAAAAAAAAAAAAAAAAAmAAAAIwAhAAAAAADCAMIAAAAiAAAANQAAAAAAAAAAAAAAswA3AAAAAABjAGQAAAAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACBAAAAIgAAACMAIwAAACEAAAArACMAAAAAACIAAAAiAAAAIwAiACIAHAAeAMEAwgDDADUAwQDCAMIAwgDCAMMAAAAnAAAAAAAAAAAAAAATAAAAAAAAAAAAAAAAAAAAAAAFAQAAkQByAJIAAAAAACIAIwAAACIAIwAAAAAAAAAAACEAMgAhAAAAJgAhACEAAAAcABoAGwAAABkAGgAaAB0AHgAeAAAAAAAAACYAAAAAAC0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALQAAAAAAAAAAAAAAAAAAAAAAAAA1AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACUAAAAtAAAAAAAAAAAAAAA3AAAAAAAAAAAAAAAhAAAAAAAjAAAAAAAmAC0AAAAiACIAAAAAAAAAIQAAAAAAAAA1AAAAAAAAAAAAKAAAACYAAAAAADIAAAAAAAAAKQAAAAAAAAAAAAAAAAAAAAAAAAAAACgAAAAAACYAKAAlACEAIwAtACIAAAAhAAAAAAAAACEAKQAAAAAAAAAAACMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMwAAAC4AAAAAADQAAAAAACUAAAAAAAAAAAAAAAAAAAAlAAAAAAAjACMAIwAAADIAAAAAAAAAAAAAAC0AJgAAAAAAIQAjAAAAAAAiACEALQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0AAAAAAAuAAAAAAAAAAAAAAAAAAAAJgAAAAAAKAAmACIAIQAiACMAJgAAAAAAAAAAAAAAIQAmAC0AIwAAAC0AIwAAAAAAAAAiAAAAAAAAAAAAAAAAAAAAAAAAADcAAAAAAAAANAAAAAAAAAAuAAAAAAAAADYAAAAAACkAAAAAAAAAJQAiAAAAJgAiAAAAAAAAAAAAAAAAAAAAAAAAAAAAIgAjACMAAAAmAAAAIgAhACEAAAAxAAAAJgBhAGIAAAAAAAAAAAAmAC4AAAAAAAAAAAAAAAAAAAAAADYAAAAAAAAAKAAlACYAJwAjAAAAAAAAAAAAAAAAAAAAAAAAACIAAAAjAAAAIgAjAAAAAAAjACMAIgA3ACEAIwAjACIAIwAhAGEAYgAhAAAAAAAuAAAAAAAAADYAAAAAAAAAAAAAAAAAAAAhACMAJQAAACYAAAAAACIAAAAAAAAAAAAAAAAAAAAAACEAAAAyAAAAIwAjAAAAAAAAAAAAAAAAACEAAAAAAAAAAAAAACMAIgAiACkANAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIgAlAAAAAAAAAAAAJgAAAAAAAAAAAAAAAAAAAAAAJgAAAAAAIwAhACMAIwAjACMAAAAjACIAAAAAAGEAYgAAACYAAAAAAAAAAAAAAC4AAAAAADYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAhAAAAIQAmACIAAAAiACIAIQAAACIAAAAAAAAAAAAAAAAAAABhAGIALgAAADYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIgAhAAAAAAAAAAAAIwAAAAAAAAAAAAAAAAAAAAAAAAA2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIwAjAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMgAAACIALQBjAGQAAAAoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACEALgAmADEAIgAiAAAAAAAAAAAAAAAAACgANAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiAAAAAAAAAC0AIgAtAAAAAAAjACIAIQAAAAAAAAAjAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACIAAAAjAAAALgAiACMAJgAAACEAIwAjACEAIwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIgAAAAAAIgAAAC0AAAAjACMAAAAyADEAIgAtAAAAIwAiAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALgAhACYAAAAuACIAAAAjACMAAAAmACEAAAAiAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACEAAAAtAC4AAAAxACIAAAAjACMALQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALgAAACMAAAAjACYAAAAtAAAAAAAjAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACIAAAAiACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="));
        //print(Base64Decode("AQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAAACAAIAAgABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAEAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAAAAAAAAAAAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAEAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAQAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwABAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAEAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAQACAAIAAgACAAIAAgACAAIAAgACAAIAAgABAAEAAQABAAEAAQACAAIAAgACAAIAAgACAAIAAgACAAIAAgABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwABAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAEAAQABAAEAAQABAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAEAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAQAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwABAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAEAAQABAAEAAQAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAACAAIAAgACAAIAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAQABAAEAAQABAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQA="));
        //print(Base64Decode("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="));
        //print(Base64Decode("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABUVFRUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFQAAFQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVAAAVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABUAABUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFRUVFQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="));
    }

    // Update is called once per frame
    void Update()
    {

    }

    //public string Base64Decode(string str)
    //{
    //    byte[] bytes = System.Convert.FromBase64String(str);
    //    print(bytes.Length);
    //    byte[] n = new byte[bytes.Length / 2];
    //    for (int i = 0; i < bytes.Length; i += 2)
    //    {
    //        print(bytes[i] + "," + bytes[i + 1]);
    //        n[i / 2] = bytes[i];
    //    }
    //    print(System.Convert.ToBase64String(n));
    //    return System.Text.Encoding.Default.GetString(bytes);
    //}
}

public class LuaManager
{ // 单例，因为我们需要保证场景中只有一个实例

    private static LuaManager instance;
    public static LuaManager Instance
    {
        get
        {
            if (instance == null)
                instance = new LuaManager();
            return instance;
        }
    }

    public Dictionary<string, string> luaScripts; // 保存脚本信息

    private LuaManager()
    { // 初始化
        luaScripts = new Dictionary<string, string>();
    }

    public string GetScripts(string methodName) // 获取脚本
    {
        if (!luaScripts.ContainsKey(methodName))
            return null;
        return luaScripts[methodName];
    }

    public void SetScripts(string methodName, string scripts) // 设置脚本，就是加载AB包额时候用到的
    {
        if (luaScripts.ContainsKey(methodName))
        {
            luaScripts[methodName] = scripts;
        }
        else
        {
            luaScripts.Add(methodName, scripts);
        }
    }

    public static string RetType(object o) // 通过反射获取自己的类名，我们的类想要取出Lua脚本就必须要知道自己的类名
    {
        System.Diagnostics.StackTrace trace = new System.Diagnostics.StackTrace();
        System.Diagnostics.StackFrame frame = trace.GetFrame(1);
        MethodBase method = frame.GetMethod();
        string className = method.ReflectedType.Name;
        return className;
    }
}

public class ObjectManager
{
    private static ObjectManager instance;
    public static ObjectManager Instance
    {
        get
        {
            if (instance == null)
                instance = new ObjectManager();
            return instance;
        }
    }

    public Dictionary<string, UnityEngine.Object> Os; // 保存GO信息

    private ObjectManager()
    { // 初始化
        Os = new Dictionary<string, UnityEngine.Object>();
    }

    public UnityEngine.Object GetO(string name) // 获取脚本
    {
        if (!Os.ContainsKey(name))
            return null;
        return Os[name];
    }

    public void SetO(string name, UnityEngine.Object go) // 设置脚本，就是加载AB包额时候用到的
    {
        if (Os.ContainsKey(name))
        {
            Os[name] = go;
        }
        else
        {
            Os.Add(name, go);
        }
    }
}

public class Tools
{
    private static Tools instance;
    public static Tools Instance
    {
        get
        {
            if (instance == null)
                instance = new Tools();
            return instance;
        }
    }

    private Tools()
    {

    }

    public int RandomRangeInt(int a, int b)
    {
        return UnityEngine.Random.Range(a, b);
    }

    public float RandomRangeFloat(float a, float b)
    {
        return UnityEngine.Random.Range(a, b);
    }

    public RaycastHit2D[] RigidBody2DCastA(Rigidbody2D r2D, Vector2 dr, RaycastHit2D[] r)
    {
        r2D.Cast(dr, r);
        return r;
    }

    public RaycastHit2D[] RigidBody2DCastB(Rigidbody2D r2D, Vector2 dr, ContactFilter2D c, RaycastHit2D[] r)
    {
        r2D.Cast(dr, c, r);
        return r;
    }

    public RaycastHit2D[] RigidBody2DCastC(Rigidbody2D r2D, Vector2 dr, RaycastHit2D[] r, float ds)
    {
        r2D.Cast(dr, r, ds);
        return r;
    }

    public List<RaycastHit2D> RigidBody2DCastD(Rigidbody2D r2D, Vector2 dr, List<RaycastHit2D> r, float ds)
    {
        r2D.Cast(dr, r, ds);
        return r;
    }

    public RaycastHit2D[] RigidBody2DCastE(Rigidbody2D r2D, Vector2 dr, ContactFilter2D c, RaycastHit2D[] r, float ds)
    {
        r2D.Cast(dr, c, r, ds);
        return r;
    }

    public List<RaycastHit2D> RigidBody2DCastF(Rigidbody2D r2D, Vector2 dr, ContactFilter2D c, List<RaycastHit2D> r, float ds)
    {
        r2D.Cast(dr, c, r, ds);
        return r;
    }

    public RaycastHit PhysicsBoxCastG(Vector3 center, Vector3 halfExtents, Vector3 direction, Quaternion orientation, float maxDistance)
    {
        RaycastHit hitInfo;
        bool r = Physics.BoxCast(center, halfExtents, direction, out hitInfo, orientation, maxDistance);
        Debug.Log(r);
        return hitInfo;
    }

    public RaycastHit[] PhysicsBoxCastAllC(Vector3 center, Vector3 halfExtents, Vector3 direction, Quaternion orientation, float maxDistance)
    {
        return Physics.BoxCastAll(center, halfExtents, direction, orientation, maxDistance);
    }

    public Collider2D[] RigidBody2DOverlapColliderA(Rigidbody2D r2D, ContactFilter2D c, Collider2D[] r)
    {
        r2D.OverlapCollider(c, r);
        return r;
    }

    public List<Collider2D> RigidBody2DOverlapColliderB(Rigidbody2D r2D, ContactFilter2D c, List<Collider2D> r)
    {
        r2D.OverlapCollider(c, r);
        return r;
    }

    public List<Collider2D> Collider2DOverlapCollider(BoxCollider2D bc2D, ContactFilter2D cf2D)
    {
        List<Collider2D> r = new List<Collider2D>();
        bc2D.OverlapCollider(cf2D, r);
        return r;
    }
}