using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class test : MonoBehaviour
{
    public LayerMask layerMask;
    private ContactFilter2D cf2d;

    [Range(0,720)]
    public float a = 0;
    [Range(0, 720)]
    public float b = 0;
    private Vector2 n = Vector2.zero;
    // Start is called before the first frame update
    void Start()
    {
        print(layerMask.value);
        layerMask = new LayerMask();
        layerMask.value = -1;

        cf2d = new ContactFilter2D
        {
            useNormalAngle = true,
            useOutsideNormalAngle = true
        };
    }

    // Update is called once per frame
    void Update()
    {
        cf2d.SetNormalAngle(a, b);

        if (Input.GetMouseButton(0))
        {
            n = Camera.main.ScreenToWorldPoint(Input.mousePosition);
        }


        if (cf2d.IsFilteringNormalAngle(n.normalized))
        {
            Debug.DrawLine(Camera.main.transform.position, Camera.main.transform.position + new Vector3(n.normalized.x, n.normalized.y, Camera.main.transform.position.z), Color.yellow);
        }
        else
        {
            Debug.DrawLine(Camera.main.transform.position, Camera.main.transform.position + new Vector3(n.normalized.x, n.normalized.y, Camera.main.transform.position.z), Color.white);
        }
        
    }
}
