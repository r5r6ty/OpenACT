//Attach this script to an empty GameObject. Create 2 more GameObjects and attach a Collider component on each. Choose these as the "My Object" and "New Object" in the Inspector.
//This script allows you to move your main GameObject left to right. If it intersects with the other, it outputs the message to the Console.

using System.Collections.Generic;
using UnityEngine;

public class ffffff : MonoBehaviour
{
    private const float MIN_MOVE_DISTANCE = 0.001f;


    public GameObject m_NewObject;
    BoxCollider2D m_Collider;
    //CompositeCollider2D m_Collider2;
    BoxCollider2D m_Collider2;

    Rigidbody2D rigid;

    public Vector2 velocity;

    public Vector3 ccc;
    public Vector3 rrr;
    public Vector3 xxx;
    public Vector3 mmm;
    public float distance;
    float proj, proj2, proj3;

    public BoxCollider2D[] asd;

    private ContactFilter2D contactFilter2D;
    private List<RaycastHit2D> raycastHit2DList = new List<RaycastHit2D>();
    private List<RaycastHit2D> tangentRaycastHit2DList = new List<RaycastHit2D>();
    void Start()
    {
        //Check that the first GameObject exists in the Inspector and fetch the Collider
            m_Collider = gameObject.GetComponent<BoxCollider2D>();

        //Check that the second GameObject exists in the Inspector and fetch the Collider
        if (m_NewObject != null)
            m_Collider2 = m_NewObject.GetComponent<BoxCollider2D>();

        rigid = gameObject.AddComponent<Rigidbody2D>();
        rigid.bodyType = RigidbodyType2D.Kinematic;
        rigid.simulated = true;
        rigid.useFullKinematicContacts = false;
        rigid.collisionDetectionMode = CollisionDetectionMode2D.Continuous;
        rigid.sleepMode = RigidbodySleepMode2D.NeverSleep;
        rigid.interpolation = RigidbodyInterpolation2D.Interpolate;
        rigid.constraints = RigidbodyConstraints2D.FreezeRotation;
        rigid.gravityScale = 0;

        contactFilter2D = new ContactFilter2D
        {
            useLayerMask = false,
            useTriggers = false,
            //layerMask = layerMask
        };
    }

    void Update()
    {
        //Vector2 oriPos = rigid.position;//记录原来的位置
        //transform.Translate(velocity * Time.deltaTime); //移动
        //float length = (rigid.position - oriPos).magnitude;//射线的长度
        //Vector2 direction = rigid.position - oriPos;//方向
        //List<RaycastHit2D> hitinfo = new List<RaycastHit2D>();
        //int isCollider = Physics2D.Raycast(oriPos,  direction, contactFilter2D, hitinfo, length);//在两个位置之间发起一条射线，然后通过这条射线去检测有没有发生碰撞
        ////if (isCollider > 0)
        ////{
        ////    for (int i = 0; i < hitinfo.Count; i++)
        ////    {
        ////        if (hitinfo[i].collider != m_Collider)
        ////        {
        ////            //Movement(velocity);
        ////            castALL()
        ////            print("wawa");
        ////        }

        ////    }
        ////}
        //castONE(hitinfo, direction);

    }

    void FixedUpdate()
    {

        //If the first GameObject's Bounds enters the second GameObject's Bounds, output the message
        //if (m_Collider.bounds.Intersects(m_Collider2.bounds))
        //{
        //    Intersects(m_Collider.bounds, m_Collider2.bounds);
        //}

        ColliderDistance2D cd2d = m_Collider.Distance(m_Collider2);
        ////cd2d.normal;
        ////distance = cd2d.distance;
        //if (cd2d.isOverlapped == true)
        //{
        //    Debug.DrawLine(cd2d.pointA, cd2d.pointA + cd2d.normal / 5, Color.yellow);
        //    Debug.DrawLine(cd2d.pointB, cd2d.pointB + cd2d.normal / 10, Color.red);
        //}
        velocity += new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical")) / 10;
        //velocity += Physics2D.gravity / 500;
        //rigid.position += velocity * Time.deltaTime;
        //rigid.position = rigid.position + velocity;


        MMMMM(velocity * Time.deltaTime);


        //rigid.velocity += Physics2D.gravity * Time.deltaTime * Time.deltaTime;
    }

    private void MMMMM(Vector2 deltaPosition)
    {
        Vector2 updateDeltaPosition = Vector2.zero;
        updateDeltaPosition += Moudle(deltaPosition);
        rigid.position += updateDeltaPosition;
    }

    Vector2 Moudle(Vector2 deltaPosition)
    {
        Vector2 updateDeltaPosition = Vector2.zero;

        float distance = deltaPosition.magnitude;
        Vector2 direction = deltaPosition.normalized;

        if (distance <= MIN_MOVE_DISTANCE)
            distance = MIN_MOVE_DISTANCE;

        Vector2 finalDirection = direction;
        float finalDistance = distance;

        List<Collider2D> a = new List<Collider2D>();
        m_Collider.OverlapCollider(contactFilter2D, a);
        for (int i = 0; i < a.Count; i++)
        {
            Collider2D bbb = a[i];
            if (m_Collider.bounds.Intersects(bbb.bounds)) // && m_Collider.bounds.Contains(hit2.point) //  && (m_Collider.bounds.Contains(cd2d.pointB) || hit2.collider.bounds.Contains(cd2d.pointA))
            {
                Vector3 menseki = IntersectsMenseki(m_Collider.bounds, bbb.bounds);
                //print(menseki);
                if (menseki != Vector3.zero)
                {
                    ColliderDistance2D cd2d = m_Collider.Distance(bbb);
                    Vector2 hitnormal = -cd2d.normal;

                    Debug.DrawLine(cd2d.pointA, cd2d.pointA + direction / 5, Color.yellow);
                    Debug.DrawLine(cd2d.pointB, cd2d.pointB + direction / 10, Color.red);

                    Debug.DrawLine(cd2d.pointA, cd2d.pointA + hitnormal / 5, Color.yellow);
                    Debug.DrawLine(cd2d.pointB, cd2d.pointB + hitnormal / 10, Color.red);

                    //Debug.DrawLine(eltaPosition.normalized, cd2d.normal, Color.red);

                    float moveDistance = 0;

                    Vector2 temp = menseki * hitnormal;
                    moveDistance = -temp.magnitude;

                    float projection = Vector2.Dot(hitnormal, direction);
                    proj = projection;
                    //if (projection != 0)0
                    //{
                    //    Vector2 off = menseki * cd2d.normal;

                    //    m_Collider.attachedRigidbody.position += off;
                    //}
                    if (projection >= 0)
                    {
                        moveDistance = distance;
                    }
                    else
                    {
                        Vector2 tangentDirection = new Vector2(hitnormal.y, -hitnormal.x);
                        float tangentDot = Vector2.Dot(tangentDirection, direction);
                        proj2 = tangentDot;

                        if (tangentDot < 0)
                        {
                            tangentDirection = -tangentDirection;
                            tangentDot = -tangentDot;
                        }

                        Vector2 tangentDeltaPosition = tangentDot * distance * tangentDirection;

                        if (tangentDot != 0)
                        {


                            updateDeltaPosition += Moudle(tangentDeltaPosition);
                        }
                    }

                    if (moveDistance < finalDistance)
                    {
                        finalDistance = moveDistance;
                    }
                }
            }
        }



        updateDeltaPosition += finalDirection * finalDistance;

        return updateDeltaPosition;
    }

    private void Movement(Vector2 deltaPosition)
    {
        List<Collider2D> a = new List<Collider2D>();
        m_Collider.OverlapCollider(contactFilter2D, a);
        castALL(a, deltaPosition);

    }

    void castONE(List<RaycastHit2D> hit, Vector2 deltaPosition)
    {
        for (int i = 0; i < hit.Count; i++)
        {
            if (hit[i].collider != m_Collider)
            {


                Collider2D bbb = hit[i].collider;
                if (MyIntersects(m_Collider.bounds, Vector3.zero, bbb.bounds, Vector3.zero)) // && m_Collider.bounds.Contains(hit2.point) //  && (m_Collider.bounds.Contains(cd2d.pointB) || hit2.collider.bounds.Contains(cd2d.pointA))
                {
                    ColliderDistance2D cd2d = m_Collider.Distance(bbb);
                    //Vector3 temp2;
                    //if (cd2d.normal == Vector2.right || cd2d.normal == Vector2.up)
                    //{
                    //    temp2 = Intersects(m_Collider2.bounds, m_Collider.bounds);
                    //}
                    //else
                    //{
                    //    temp2 = Intersects(m_Collider.bounds, m_Collider2.bounds);
                    //}
                    //Vector3 p2 = new Vector3(temp2.x, 0, 0);
                    //transform.position += p;
                    Debug.DrawLine(cd2d.pointA, cd2d.pointA + cd2d.normal / 5, Color.yellow);
                    Debug.DrawLine(cd2d.pointB, cd2d.pointB + cd2d.normal / 10, Color.red);

                    //Debug.DrawLine(eltaPosition.normalized, cd2d.normal, Color.red);

                    float projection = Vector2.Dot(deltaPosition.normalized, cd2d.normal);

                    if (projection != 0)
                    {
                        Vector3 temp = Vector3.zero;
                        if (m_Collider.bounds.center.x < bbb.bounds.center.x)
                        {
                            temp = new Vector3(bbb.bounds.min.x - m_Collider.bounds.extents.x - m_Collider.offset.x, temp.y, 0);
                        }
                        else
                        {
                            temp = new Vector3(bbb.bounds.max.x + m_Collider.bounds.extents.x - m_Collider.offset.x, temp.y, 0);
                        }
                        if (m_Collider.bounds.center.y > bbb.bounds.center.y)
                        {
                            temp = new Vector3(temp.x, bbb.bounds.max.y + m_Collider.bounds.extents.y - m_Collider.offset.y, 0);
                        }
                        else
                        {
                            temp = new Vector3(temp.x, bbb.bounds.min.y - m_Collider.bounds.extents.y - m_Collider.offset.y, 0);
                        }

                        Vector3 ttt = new Vector3((temp.x) * Mathf.Abs(cd2d.normal.x), (temp.y) * Mathf.Abs(cd2d.normal.y), 0);
                        if (ttt.x == 0.0f)
                        {
                            m_Collider.attachedRigidbody.position = new Vector3(m_Collider.attachedRigidbody.position.x, ttt.y, 0);
                            //print("wocao1" + "," + ttt.y);
                        }
                        else if (ttt.y == 0.0f)
                        {
                            m_Collider.attachedRigidbody.position = new Vector3(ttt.x, m_Collider.attachedRigidbody.position.y, 0);
                            //print("wocao2" + "," + m_Collider.attachedRigidbody.position.y);
                        }
                        else
                        {
                            m_Collider.attachedRigidbody.position = ttt;
                            //print("wocao3" + "," + ttt);
                        }
                    }

                }
            }
        }
    }

    void castALL(List<Collider2D> sss, Vector2 deltaPosition)
    {
        for (int i = 0; i < sss.Count; i++)
        {
            Collider2D bbb = sss[i];
            if (MyIntersects(m_Collider.bounds, Vector3.zero, bbb.bounds, Vector3.zero)) // && m_Collider.bounds.Contains(hit2.point) //  && (m_Collider.bounds.Contains(cd2d.pointB) || hit2.collider.bounds.Contains(cd2d.pointA))
            {
                ColliderDistance2D cd2d = m_Collider.Distance(bbb);
                //Vector3 temp2;
                //if (cd2d.normal == Vector2.right || cd2d.normal == Vector2.up)
                //{
                //    temp2 = Intersects(m_Collider2.bounds, m_Collider.bounds);
                //}
                //else
                //{
                //    temp2 = Intersects(m_Collider.bounds, m_Collider2.bounds);
                //}
                //Vector3 p2 = new Vector3(temp2.x, 0, 0);
                //transform.position += p;
                Debug.DrawLine(cd2d.pointA, cd2d.pointA + cd2d.normal / 5, Color.yellow);
                Debug.DrawLine(cd2d.pointB, cd2d.pointB + cd2d.normal / 10, Color.red);

                //Debug.DrawLine(eltaPosition.normalized, cd2d.normal, Color.red);

                float projection = Vector2.Dot(deltaPosition.normalized, cd2d.normal);

                if (projection != 0)
                {
                    Vector3 temp = Vector3.zero;
                    if (m_Collider.bounds.center.x < bbb.bounds.center.x)
                    {
                        temp = new Vector3(bbb.bounds.min.x - m_Collider.bounds.extents.x - m_Collider.offset.x, temp.y, 0);
                    }
                    else
                    {
                        temp = new Vector3(bbb.bounds.max.x + m_Collider.bounds.extents.x - m_Collider.offset.x, temp.y, 0);
                    }
                    if (m_Collider.bounds.center.y > bbb.bounds.center.y)
                    {
                        temp = new Vector3(temp.x, bbb.bounds.max.y + m_Collider.bounds.extents.y - m_Collider.offset.y, 0);
                    }
                    else
                    {
                        temp = new Vector3(temp.x, bbb.bounds.min.y - m_Collider.bounds.extents.y - m_Collider.offset.y, 0);
                    }

                    Vector3 ttt = new Vector3((temp.x) * Mathf.Abs(cd2d.normal.x), (temp.y) * Mathf.Abs(cd2d.normal.y), 0);
                    if (ttt.x == 0.0f)
                    {
                        m_Collider.attachedRigidbody.position = new Vector3(m_Collider.attachedRigidbody.position.x, ttt.y, 0);
                        //print("wocao1" + "," + ttt.y);
                    }
                    else if (ttt.y == 0.0f)
                    {
                        m_Collider.attachedRigidbody.position = new Vector3(ttt.x, m_Collider.attachedRigidbody.position.y, 0);
                        //print("wocao2" + "," + m_Collider.attachedRigidbody.position.y);
                    }
                    else
                    {
                        m_Collider.attachedRigidbody.position = ttt;
                        //print("wocao3" + "," + ttt);
                    }
                }

            }
        }

    }
    
    RaycastHit2D carcar(RaycastHit2D hit2)
    {
        RaycastHit2D r = new RaycastHit2D();

        Vector3 temp;
        if (hit2.normal == Vector2.right || hit2.normal == Vector2.up)
        {
            temp = Intersects(m_Collider.bounds, hit2.collider.bounds);
        }
        else
        {
            temp = Intersects(hit2.collider.bounds, m_Collider.bounds);
        }
        Vector2 temp2 = temp * hit2.normal;
        //print(temp2.x + "," + temp2.y);
        r.point = temp2; //  hit2.point;// + temp2;
        r.distance = -temp2.magnitude;
        distance = r.distance;
        r.normal = hit2.normal;
        return r;
    }

    private void OnGUI()
    {
        GUILayout.Label(distance.ToString());
        GUILayout.Label(ccc.x.ToString() + "," + ccc.y.ToString() + "," + ccc.z.ToString());
        GUILayout.Label(rrr.x.ToString() + "," + rrr.y.ToString() + "," + rrr.z.ToString());
        GUILayout.Label(xxx.x.ToString() + "," + xxx.y.ToString() + "," + xxx.z.ToString());
        GUILayout.Label(proj.ToString() + "," + proj2.ToString() + "," + proj3.ToString());

        GUILayout.Label("menseki" + "," + mmm.x.ToString() + "," + mmm.y.ToString() + "," + mmm.z.ToString());
    }

    public Vector3 Intersects(Bounds lhs, Bounds rhs)
    {

        var c = lhs.center - rhs.center;
        var r = lhs.extents + rhs.extents;
        ccc = c;
        rrr = r;

        xxx = c - r;
        //var x = Mathf.Abs(c.x) <= r.x;
        //var y = Mathf.Abs(c.y) <= r.y;
        //var z = Mathf.Abs(c.z) <= r.z;

        return xxx;

    }

    public Vector3 IntersectsMenseki(Bounds lhs, Bounds rhs)
    {

        var c = lhs.center - rhs.center;
        var r = lhs.extents + rhs.extents;
        ccc = c;
        rrr = r;

        xxx = r - new Vector3(Mathf.Abs(c.x), Mathf.Abs(c.y), Mathf.Abs(c.z));
        return xxx;

    }

    public static bool MyIntersects2(Bounds lhs, Vector3 offsetl, Bounds rhs, Vector3 offsetr)
    {

        var c = (lhs.center + offsetl) - (rhs.center + offsetr);
        var r = lhs.extents + rhs.extents;

        var x = Mathf.Abs(c.x) <= r.x;
        var y = Mathf.Abs(c.y) <= r.y;
        var z = Mathf.Abs(c.z) <= r.z;

        return x & y & z;
        
    }



    public static bool MyIntersects(Bounds lhs, Vector3 offsetl, Bounds rhs, Vector3 offsetr)
    {

        var c = (lhs.center + offsetl) - (rhs.center + offsetr);
        var r = lhs.extents + rhs.extents;

        var x = Mathf.Abs(c.x) < r.x;
        var y = Mathf.Abs(c.y) < r.y;

        return x & y;

    }
}