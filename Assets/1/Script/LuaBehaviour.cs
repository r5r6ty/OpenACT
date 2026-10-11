/*
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
        //更新的时间间隔
        public float UpdateInterval = 0.5F;
        //最后的时间间隔
        private float _lastInterval;
        //帧[中间变量 辅助]
        private int _frames = 0;
        //当前的帧率
        private float _fps;

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
        private Action luaOnDrawGizmos;

        private Action<Collider2D> luaOnTriggerEnter2D;
        private Action<Collider2D> luaOnTriggerExit2D;
        private Action<Collider2D> luaOnTriggerStay2D;
        private Action<Collision2D> luaOnCollisionEnter2D;
        private Action<Collision2D> luaOnCollisionExit2D;
        private Action<Collision2D> luaOnCollisionStay2D;

        private Action<Collider> luaOnTriggerEnter;
        private Action<Collider> luaOnTriggerExit;
        private Action<Collider> luaOnTriggerStay;
        private Action<Collision> luaOnCollisionEnter;
        private Action<Collision> luaOnCollisionExit;
        private Action<Collision> luaOnCollisionStay;

        // 教程中是私有的，不过为了在lua脚本里能拿到这个变量所以改成了共有的，不知道能否这样做
        public LuaTable scriptEnv;

        private byte[] CustomLoaderMethod(ref string fileName)
        {
            // GameLoader 预载过的脚本直接从缓存拿原始字节（WebGL 没有同步文件 IO，只能走这条；
            // 存字节不存 text 是因为部分 lua 是 GBK 编码，按 UTF-8 解码会喂成乱码）
            byte[] cached = LuaManager.Instance.GetScriptBytes(fileName);
            if (cached != null)
            {
                return cached;
            }

#if UNITY_WEBGL
            Debug.LogError("CustomLoader: WebGL 下找不到未预载的脚本：" + fileName);
            return null;
#else
            // 找到指定文件
            fileName = GameLoader.Getluapath() + fileName.Replace('.', '/') + ".lua";
            if (File.Exists(fileName))
            {
                return File.ReadAllBytes(fileName);
            }
            return null;
#endif
        }

        // AddLoader 只要加一次，加多了每条 require 都会白走一遍全部 loader
        internal static bool loaderAdded = false;

        void Awake()
        {
            if (!loaderAdded)
            {
                LuaEnv.CustomLoader method = CustomLoaderMethod; // 自定义加载方法
                luaEnv.AddLoader(method); // 添加自定义装载机Loader
                loaderAdded = true;
            }

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
            // 为了能够给gameobject挂上想要的lua，必须在awake之前就让他知道要哪个lua脚本，目前用gameobject的name取
            // Instantiate 出来的物体名字带 " (Clone)" 后缀，剥掉再查
            string objName = gameObject.name.ToLower();
            if (objName.EndsWith("(clone)"))
            {
                objName = objName.Substring(0, objName.Length - "(clone)".Length).Trim();
            }
            string scripts = LuaManager.Instance.GetScripts(objName);
            if (scripts == null)
            {
                Debug.LogError("LuaBehaviour: LuaManager 里没有预载物体 " + gameObject.name + " 对应的 lua 脚本（" + objName + "）");
                return;
            }
            luaEnv.DoString(scripts, gameObject.name, scriptEnv);

            //luaEnv.DoString(@"require('test')");

            Action luaAwake = scriptEnv.Get<Action>("awake");
            scriptEnv.Get("start", out luaStart);
            scriptEnv.Get("update", out luaUpdate);
            scriptEnv.Get("fixedupdate", out luaFixedUpdate);
            scriptEnv.Get("ondestroy", out luaOnDestroy);
            scriptEnv.Get("ongui", out luaOnGui);
            scriptEnv.Get("onDrawGizmos", out luaOnDrawGizmos);

            scriptEnv.Get("onTriggerEnter2D", out luaOnTriggerEnter2D);
            scriptEnv.Get("onTriggerExit2D", out luaOnTriggerExit2D);
            scriptEnv.Get("onTriggerStay2D", out luaOnTriggerStay2D);
            scriptEnv.Get("onCollisionEnter2D", out luaOnCollisionEnter2D);
            scriptEnv.Get("onCollisionExit2D", out luaOnCollisionExit2D);
            scriptEnv.Get("onCollisionStay2D", out luaOnCollisionStay2D);

            scriptEnv.Get("onTriggerEnter", out luaOnTriggerEnter);
            scriptEnv.Get("onTriggerExit", out luaOnTriggerExit);
            scriptEnv.Get("onTriggerStay", out luaOnTriggerStay);
            scriptEnv.Get("onCollisionEnter", out luaOnCollisionEnter);
            scriptEnv.Get("onCollisionExit", out luaOnCollisionExit);
            scriptEnv.Get("onCollisionStay", out luaOnCollisionStay);

            if (luaAwake != null)
            {
                luaAwake();
            }
        }

        // Use this for initialization
        void Start()
        {
            _lastInterval = Time.realtimeSinceStartup;
            _frames = 0;
            if (luaStart != null)
            {
                luaStart();
            }
        }

        // Update is called once per frame
        void Update()
        {
            _frames++;
            if (Time.realtimeSinceStartup > _lastInterval + UpdateInterval)
            {
                _fps = _frames / (Time.realtimeSinceStartup - _lastInterval);
                _frames = 0;
                _lastInterval = Time.realtimeSinceStartup;
            }
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
            luaStart = null;
            luaUpdate = null;
            luaFixedUpdate = null;
            luaOnDestroy = null;
            luaOnGui = null;
            luaOnDrawGizmos = null;
            luaOnTriggerEnter2D = null;
            luaOnTriggerExit2D = null;
            luaOnTriggerStay2D = null;
            luaOnCollisionEnter2D = null;
            luaOnCollisionExit2D = null;
            luaOnCollisionStay2D = null;
            luaOnTriggerEnter = null;
            luaOnTriggerExit = null;
            luaOnTriggerStay = null;
            luaOnCollisionEnter = null;
            luaOnCollisionExit = null;
            luaOnCollisionStay = null;
            scriptEnv.Dispose();
            injections = null;
        }

        void OnGUI()
        {
            GUI.Label(new Rect(10, Screen.height - 40, 200, 20), "Lua Memory:" + luaEnv.Memroy + "Kb" + ", FPS: " + _fps.ToString("f2"));
            if (luaOnGui != null)
            {
                luaOnGui();
            }
        }

        void OnDrawGizmos()
        {
            if (luaOnDrawGizmos != null)
            {
                luaOnDrawGizmos();
            }
        }

        void OnTriggerEnter2D(Collider2D c)
        {
            if (luaOnTriggerEnter2D != null)
            {
                luaOnTriggerEnter2D(c);
            }
        }

        void OnTriggerExit2D(Collider2D c)
        {
            if (luaOnTriggerExit2D != null)
            {
                luaOnTriggerExit2D(c);
            }
        }

        void OnTriggerStay2D(Collider2D c)
        {
            if (luaOnTriggerStay2D != null)
            {
                luaOnTriggerStay2D(c);
            }
        }

        void OnCollisionEnter2D(Collision2D c)
        {
            if (luaOnCollisionEnter2D != null)
            {
                luaOnCollisionEnter2D(c);
            }
        }

        void OnCollisionExit2D(Collision2D c)
        {
            if (luaOnCollisionExit2D != null)
            {
                luaOnCollisionExit2D(c);
            }
        }

        void OnCollisionStay2D(Collision2D c)
        {
            if (luaOnCollisionStay2D != null)
            {
                luaOnCollisionStay2D(c);
            }
        }

        void OnTriggerEnter(Collider c)
        {
            if (luaOnTriggerEnter != null)
            {
                luaOnTriggerEnter(c);
            }
        }

        void OnTriggerExit(Collider c)
        {
            if (luaOnTriggerExit != null)
            {
                luaOnTriggerExit(c);
            }
        }

        void OnTriggerStay(Collider c)
        {
            if (luaOnTriggerStay != null)
            {
                luaOnTriggerStay(c);
            }
        }

        void OnCollisionEnter(Collision c)
        {
            if (luaOnCollisionEnter != null)
            {
                luaOnCollisionEnter(c);
            }
        }

        void OnCollisionExit(Collision c)
        {
            if (luaOnCollisionExit != null)
            {
                luaOnCollisionExit(c);
            }
        }

        void OnCollisionStay(Collision c)
        {
            if (luaOnCollisionStay != null)
            {
                luaOnCollisionStay(c);
            }
        }
    }
}
