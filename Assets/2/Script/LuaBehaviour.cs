﻿/*
 * Tencent is pleased to support the open source community by making xLua available.
 * Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using XLua;
using System;
using System.IO;

namespace XLuaTest
{
    [System.Serializable]
    public class Injection
    {
        public string name;
        public GameObject value;
    }

    [LuaCallCSharp]
    public class LuaBehaviour : MonoBehaviour
    {
        //public TextAsset luaScript;
        public Injection[] injections;

        internal static LuaEnv luaEnv = new LuaEnv(); // all lua behaviour shared one luaenv only!
        internal static float lastGCTime = 0;
        internal const float GCInterval = 1;// 1 second 

        private Action luaStart;
        private Action luaUpdate;
        private Action luaFixedUpdate;
        private Action luaOnDestroy;
        private Action luaOnGui;

        // 教程中是私有的，不过为了在lua脚本里能拿到这个变量所以改成了共有的，不知道能否这样做
        public LuaTable scriptEnv;

        private byte[] CustomLoaderMethod(ref string fileName)
        {
            // 找到指定文件
#if UNITY_EDITOR
            fileName = Application.dataPath + "/StreamingAssets/2/Lua/" + fileName.Replace('.', '/') + ".lua";
#endif
            print(fileName);
            if (File.Exists(fileName))
            {
                return File.ReadAllBytes(fileName);
            }
            else
            {
                return null;
            }
        }

        void Awake()
        {
            LuaEnv.CustomLoader method = CustomLoaderMethod; // 自定义加载方法
            // 添加自定义装载机Loader  
            luaEnv.AddLoader(method);

            scriptEnv = luaEnv.NewTable();

            // 为每个脚本设置一个独立的环境，可一定程度上防止脚本间全局变量、函数冲突
            LuaTable meta = luaEnv.NewTable();
            meta.Set("__index", luaEnv.Global);
            scriptEnv.SetMetaTable(meta);
            meta.Dispose();

            scriptEnv.Set("self", this);
            if (injections != null)
            {
                foreach (var injection in injections)
                {
                    scriptEnv.Set(injection.name, injection.value);
                }
            }

            // 教程代码
            //luaEnv.DoString(luaScript.text, "LuaTestScript", scriptEnv);

            // 通过gameobject的名字来获取对应的lua脚本
            // 为了能够给gameobject挂上想要的lua，必须在awake之前就让他知道要哪个lua脚本，目前用gameobject的name取，不知道有没有更好的方法
            string scripts = LuaManager.Instance.GetScripts(gameObject.name.ToLower());
            luaEnv.DoString(scripts, gameObject.name, scriptEnv);

            //luaEnv.DoString(@"require('test')");

            Action luaAwake = scriptEnv.Get<Action>("awake");
            scriptEnv.Get("start", out luaStart);
            scriptEnv.Get("update", out luaUpdate);
            scriptEnv.Get("fixedupdate", out luaFixedUpdate);
            scriptEnv.Get("ondestroy", out luaOnDestroy);
            scriptEnv.Get("ongui", out luaOnGui);

            if (luaAwake != null)
            {
                luaAwake();
            }
        }

        // Use this for initialization
        void Start()
        {
            if (luaStart != null)
            {
                luaStart();
            }
        }

        // Update is called once per frame
        void Update()
        {
            if (luaUpdate != null)
            {
                luaUpdate();
            }
            if (Time.time - LuaBehaviour.lastGCTime > GCInterval)
            {
                luaEnv.Tick();
                LuaBehaviour.lastGCTime = Time.time;
            }
        }

        void FixedUpdate()
        {
            if (luaFixedUpdate != null)
            {
                luaFixedUpdate();
            }
        }

        void OnDestroy()
        {
            if (luaOnDestroy != null)
            {
                luaOnDestroy();
            }
            luaOnDestroy = null;
            luaUpdate = null;
            luaStart = null;
            scriptEnv.Dispose();
            injections = null;
        }

        void OnGUI()
        {
            if (luaOnGui != null)
            {
                luaOnGui();
            }
        }
    }
}
