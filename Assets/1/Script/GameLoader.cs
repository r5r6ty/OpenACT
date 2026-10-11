using System.Collections;
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
#else
    luapath = folder + "/";
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

        if (www.isNetworkError || www.isHttpError)
        {
            Debug.LogError("读取 lua 脚本失败：" + path + " -> " + www.error);
        }
        else
        {
            string code = www.downloadHandler.text;
            string methodName = path.Replace(".lua", "");
            methodName = methodName.Substring(methodName.LastIndexOf(@"/") + 1); // 获得名称
            print(methodName);
            LuaManager.Instance.SetScripts(methodName, code); // 下面有介绍
            // 原始字节单独存一份：仓库里部分 lua 是 GBK 编码，text（按 UTF-8 解码）会喂成乱码
            LuaManager.Instance.SetScriptBytes(methodName, www.downloadHandler.data);
        }

        count++;

        if (count >= total)
        {
            init.SetActive(true);
            Destroy(gameObject);
        }
    }
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
    public Dictionary<string, byte[]> luaScriptBytes; // 保存原始字节（不按 UTF-8 解码，GBK 文件也原样）

    private LuaManager()
    { // 初始化
        luaScripts = new Dictionary<string, string>();
        luaScriptBytes = new Dictionary<string, byte[]>();
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

    public byte[] GetScriptBytes(string methodName) // 获取脚本原始字节
    {
        if (!luaScriptBytes.ContainsKey(methodName))
            return null;
        return luaScriptBytes[methodName];
    }

    public void SetScriptBytes(string methodName, byte[] bytes) // 设置脚本原始字节
    {
        if (luaScriptBytes.ContainsKey(methodName))
        {
            luaScriptBytes[methodName] = bytes;
        }
        else
        {
            luaScriptBytes.Add(methodName, bytes);
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
