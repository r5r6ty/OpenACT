#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using XLua;
using System.Collections.Generic;


namespace XLua.CSObjectWrap
{
    using Utils = XLua.Utils;
    public class ToolsWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(Tools);
			Utils.BeginObjectRegister(type, L, translator, 0, 13, 0, 0);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RandomRangeInt", _m_RandomRangeInt);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RandomRangeFloat", _m_RandomRangeFloat);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RigidBody2DCastA", _m_RigidBody2DCastA);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RigidBody2DCastB", _m_RigidBody2DCastB);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RigidBody2DCastC", _m_RigidBody2DCastC);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RigidBody2DCastD", _m_RigidBody2DCastD);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RigidBody2DCastE", _m_RigidBody2DCastE);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RigidBody2DCastF", _m_RigidBody2DCastF);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "PhysicsBoxCastG", _m_PhysicsBoxCastG);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "PhysicsBoxCastAllC", _m_PhysicsBoxCastAllC);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RigidBody2DOverlapColliderA", _m_RigidBody2DOverlapColliderA);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "RigidBody2DOverlapColliderB", _m_RigidBody2DOverlapColliderB);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Collider2DOverlapCollider", _m_Collider2DOverlapCollider);
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 1, 1, 0);
			
			
            
			Utils.RegisterFunc(L, Utils.CLS_GETTER_IDX, "Instance", _g_get_Instance);
            
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            return LuaAPI.luaL_error(L, "Tools does not have a constructor!");
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RandomRangeInt(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    int _a = LuaAPI.xlua_tointeger(L, 2);
                    int _b = LuaAPI.xlua_tointeger(L, 3);
                    
                        int gen_ret = gen_to_be_invoked.RandomRangeInt( _a, _b );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RandomRangeFloat(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    float _a = (float)LuaAPI.lua_tonumber(L, 2);
                    float _b = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        float gen_ret = gen_to_be_invoked.RandomRangeFloat( _a, _b );
                        LuaAPI.lua_pushnumber(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RigidBody2DCastA(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Rigidbody2D _r2D = (UnityEngine.Rigidbody2D)translator.GetObject(L, 2, typeof(UnityEngine.Rigidbody2D));
                    UnityEngine.Vector2 _dr;translator.Get(L, 3, out _dr);
                    UnityEngine.RaycastHit2D[] _r = (UnityEngine.RaycastHit2D[])translator.GetObject(L, 4, typeof(UnityEngine.RaycastHit2D[]));
                    
                        UnityEngine.RaycastHit2D[] gen_ret = gen_to_be_invoked.RigidBody2DCastA( _r2D, _dr, _r );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RigidBody2DCastB(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Rigidbody2D _r2D = (UnityEngine.Rigidbody2D)translator.GetObject(L, 2, typeof(UnityEngine.Rigidbody2D));
                    UnityEngine.Vector2 _dr;translator.Get(L, 3, out _dr);
                    UnityEngine.ContactFilter2D _c;translator.Get(L, 4, out _c);
                    UnityEngine.RaycastHit2D[] _r = (UnityEngine.RaycastHit2D[])translator.GetObject(L, 5, typeof(UnityEngine.RaycastHit2D[]));
                    
                        UnityEngine.RaycastHit2D[] gen_ret = gen_to_be_invoked.RigidBody2DCastB( _r2D, _dr, _c, _r );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RigidBody2DCastC(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Rigidbody2D _r2D = (UnityEngine.Rigidbody2D)translator.GetObject(L, 2, typeof(UnityEngine.Rigidbody2D));
                    UnityEngine.Vector2 _dr;translator.Get(L, 3, out _dr);
                    UnityEngine.RaycastHit2D[] _r = (UnityEngine.RaycastHit2D[])translator.GetObject(L, 4, typeof(UnityEngine.RaycastHit2D[]));
                    float _ds = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        UnityEngine.RaycastHit2D[] gen_ret = gen_to_be_invoked.RigidBody2DCastC( _r2D, _dr, _r, _ds );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RigidBody2DCastD(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Rigidbody2D _r2D = (UnityEngine.Rigidbody2D)translator.GetObject(L, 2, typeof(UnityEngine.Rigidbody2D));
                    UnityEngine.Vector2 _dr;translator.Get(L, 3, out _dr);
                    System.Collections.Generic.List<UnityEngine.RaycastHit2D> _r = (System.Collections.Generic.List<UnityEngine.RaycastHit2D>)translator.GetObject(L, 4, typeof(System.Collections.Generic.List<UnityEngine.RaycastHit2D>));
                    float _ds = (float)LuaAPI.lua_tonumber(L, 5);
                    
                        System.Collections.Generic.List<UnityEngine.RaycastHit2D> gen_ret = gen_to_be_invoked.RigidBody2DCastD( _r2D, _dr, _r, _ds );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RigidBody2DCastE(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Rigidbody2D _r2D = (UnityEngine.Rigidbody2D)translator.GetObject(L, 2, typeof(UnityEngine.Rigidbody2D));
                    UnityEngine.Vector2 _dr;translator.Get(L, 3, out _dr);
                    UnityEngine.ContactFilter2D _c;translator.Get(L, 4, out _c);
                    UnityEngine.RaycastHit2D[] _r = (UnityEngine.RaycastHit2D[])translator.GetObject(L, 5, typeof(UnityEngine.RaycastHit2D[]));
                    float _ds = (float)LuaAPI.lua_tonumber(L, 6);
                    
                        UnityEngine.RaycastHit2D[] gen_ret = gen_to_be_invoked.RigidBody2DCastE( _r2D, _dr, _c, _r, _ds );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RigidBody2DCastF(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Rigidbody2D _r2D = (UnityEngine.Rigidbody2D)translator.GetObject(L, 2, typeof(UnityEngine.Rigidbody2D));
                    UnityEngine.Vector2 _dr;translator.Get(L, 3, out _dr);
                    UnityEngine.ContactFilter2D _c;translator.Get(L, 4, out _c);
                    System.Collections.Generic.List<UnityEngine.RaycastHit2D> _r = (System.Collections.Generic.List<UnityEngine.RaycastHit2D>)translator.GetObject(L, 5, typeof(System.Collections.Generic.List<UnityEngine.RaycastHit2D>));
                    float _ds = (float)LuaAPI.lua_tonumber(L, 6);
                    
                        System.Collections.Generic.List<UnityEngine.RaycastHit2D> gen_ret = gen_to_be_invoked.RigidBody2DCastF( _r2D, _dr, _c, _r, _ds );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PhysicsBoxCastG(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Vector3 _center;translator.Get(L, 2, out _center);
                    UnityEngine.Vector3 _halfExtents;translator.Get(L, 3, out _halfExtents);
                    UnityEngine.Vector3 _direction;translator.Get(L, 4, out _direction);
                    UnityEngine.Quaternion _orientation;translator.Get(L, 5, out _orientation);
                    float _maxDistance = (float)LuaAPI.lua_tonumber(L, 6);
                    
                        UnityEngine.RaycastHit gen_ret = gen_to_be_invoked.PhysicsBoxCastG( _center, _halfExtents, _direction, _orientation, _maxDistance );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PhysicsBoxCastAllC(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Vector3 _center;translator.Get(L, 2, out _center);
                    UnityEngine.Vector3 _halfExtents;translator.Get(L, 3, out _halfExtents);
                    UnityEngine.Vector3 _direction;translator.Get(L, 4, out _direction);
                    UnityEngine.Quaternion _orientation;translator.Get(L, 5, out _orientation);
                    float _maxDistance = (float)LuaAPI.lua_tonumber(L, 6);
                    
                        UnityEngine.RaycastHit[] gen_ret = gen_to_be_invoked.PhysicsBoxCastAllC( _center, _halfExtents, _direction, _orientation, _maxDistance );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RigidBody2DOverlapColliderA(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Rigidbody2D _r2D = (UnityEngine.Rigidbody2D)translator.GetObject(L, 2, typeof(UnityEngine.Rigidbody2D));
                    UnityEngine.ContactFilter2D _c;translator.Get(L, 3, out _c);
                    UnityEngine.Collider2D[] _r = (UnityEngine.Collider2D[])translator.GetObject(L, 4, typeof(UnityEngine.Collider2D[]));
                    
                        UnityEngine.Collider2D[] gen_ret = gen_to_be_invoked.RigidBody2DOverlapColliderA( _r2D, _c, _r );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_RigidBody2DOverlapColliderB(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Rigidbody2D _r2D = (UnityEngine.Rigidbody2D)translator.GetObject(L, 2, typeof(UnityEngine.Rigidbody2D));
                    UnityEngine.ContactFilter2D _c;translator.Get(L, 3, out _c);
                    System.Collections.Generic.List<UnityEngine.Collider2D> _r = (System.Collections.Generic.List<UnityEngine.Collider2D>)translator.GetObject(L, 4, typeof(System.Collections.Generic.List<UnityEngine.Collider2D>));
                    
                        System.Collections.Generic.List<UnityEngine.Collider2D> gen_ret = gen_to_be_invoked.RigidBody2DOverlapColliderB( _r2D, _c, _r );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Collider2DOverlapCollider(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Tools gen_to_be_invoked = (Tools)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.BoxCollider2D _bc2D = (UnityEngine.BoxCollider2D)translator.GetObject(L, 2, typeof(UnityEngine.BoxCollider2D));
                    UnityEngine.ContactFilter2D _cf2D;translator.Get(L, 3, out _cf2D);
                    
                        System.Collections.Generic.List<UnityEngine.Collider2D> gen_ret = gen_to_be_invoked.Collider2DOverlapCollider( _bc2D, _cf2D );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_Instance(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			    translator.Push(L, Tools.Instance);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
		
		
		
		
    }
}
