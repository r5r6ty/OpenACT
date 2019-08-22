using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LayerMaskTest : MonoBehaviour
{
    public BoxCollider2D aaa;
    BoxCollider2D bbb = null;

    public ContactFilter2D CF2D;
    int count = 0;
    // Start is called before the first frame update
    void Start()
    {
        aaa.gameObject.layer = 6;

        bbb = gameObject.GetComponent<BoxCollider2D>();
        print(gameObject.layer);

        CF2D.useLayerMask = true;

        LayerMask k = new LayerMask();
        string[] sss = {"UI"};
        k.value = 64;
        print(k.value);

        CF2D.SetLayerMask(k);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void FixedUpdate()
    {
        List<Collider2D> list = new List<Collider2D>();
        count = bbb.OverlapCollider(CF2D, list);
    }

    void OnGUI()
    {
        GUILayout.Label(count.ToString());
    }
}
