-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

local tile_size = 4
local tile_sprite = CS.UnityEngine.Sprite.Create(CS.UnityEngine.Texture2D(tile_size, tile_size), CS.UnityEngine.Rect(0, 0, tile_size, tile_size), CS.UnityEngine.Vector2(0, 1))

function roundm(n, m)
    return math.floor(((n + m - 1) / m)) * m
end

function getRandomPointInCircle(radius)
    local t = 2 * math.pi * math.random()
    local u = math.random() + math.random()
    local r = nil
    if u > 1 then r = 2 - u else r = u end
    return roundm(radius * r * math.cos(t), tile_size / 100), 
           roundm(radius * r * math.sin(t), tile_size / 100)
end

function getRandomPointInEllipse(ellipse_width, ellipse_height)
    local t = 2 * math.pi * math.random()
    local u = math.random() + math.random()
    local r = nil
    if u > 1 then r = 2 - u else r = u end
    return roundm(ellipse_width * r * math.cos(t) / 2, tile_size), 
           roundm(ellipse_height * r * math.sin(t) / 2, tile_size)
end

function createEmptyUnityObject(name, x, y)
    local unityobject = CS.UnityEngine.GameObject(name)
    unityobject.transform.position = CS.UnityEngine.Vector3(x / 100, y / 100, 0)
    return unityobject
end

function createUnityObject(p, name, x, y, width, height)
--    local unityobject = CS.UnityEngine.GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Quad)
    local unityobject = CS.UnityEngine.GameObject(name)
    unityobject.transform.parent = p.transform
    unityobject.transform.position = CS.UnityEngine.Vector3(x / 100, y / 100, 0)
--    unityobject.transform.localScale = CS.UnityEngine.Vector3(width / 100, height / 100, 0)
--    unityobject:AddComponent(typeof(CS.UnityEngine.RectTransform))
--    local image = unityobject:AddComponent(typeof(CS.UnityEngine.UI.Image))
--    image.rectTransform.sizeDelta = CS.UnityEngine.Vector2(width, height)
--    CS.UnityEngine.Object.Destroy(unityobject:GetComponent(typeof(CS.UnityEngine.MeshCollider)))
    for i_y = 0, height - 1, 1 do
        for i_x = 0, width - 1, 1 do
            local unityobject_child = CS.UnityEngine.GameObject(block)
            unityobject_child.transform.parent = unityobject.transform
            unityobject_child.transform.localPosition = CS.UnityEngine.Vector3(i_x * tile_size / 100, -i_y * tile_size / 100, 0)
            local sr = unityobject_child:AddComponent(typeof(CS.UnityEngine.SpriteRenderer))
            sr.sprite = tile_sprite
        end
    end
    local bc2d = unityobject:AddComponent(typeof(CS.UnityEngine.BoxCollider2D))
    bc2d.offset = CS.UnityEngine.Vector2(width * 4 / 100 / 2, -height * 4 / 100 / 2)
    bc2d.size = CS.UnityEngine.Vector2(width * 4 / 100, height * 4 / 100)
--    bc2d.enabled = false
    local f = CS.UnityEngine.PhysicsMaterial2D("test");
    f.friction = 0;
    bc2d.sharedMaterial = f
    local rb2d = unityobject:AddComponent(typeof(CS.UnityEngine.Rigidbody2D))
    rb2d.freezeRotation = true
    rb2d.gravityScale = 0
    rb2d.angularDrag = 1
    rb2d.drag = 1
    rb2d.interpolation = CS.UnityEngine.RigidbodyInterpolation2D.Interpolate
    rb2d.useAutoMass = true

    local script = unityobject:AddComponent(typeof(CS.XLuaTest.LuaBehaviour))
    script.scriptEnv.map_size.w = width
    script.scriptEnv.map_size.h = height
    return script
end

function getIntPart(x)
    if x <= 0 then
        return math.ceil(x);
    end

    if math.ceil(x) == x then
       x = math.ceil(x);
    else
       x = math.ceil(x) - 1;
    end
    return x;
end