//Attach this script to an empty GameObject. Create 2 more GameObjects and attach a Collider component on each. Choose these as the "My Object" and "New Object" in the Inspector.
//This script allows you to move your main GameObject left to right. If it intersects with the other, it outputs the message to the Console.

using System.Collections.Generic;
using UnityEngine;

public class BoundsIntersectExample : MonoBehaviour
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
    public float distance;
    float proj;

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

        rigid = gameObject.GetComponent<Rigidbody2D>();
        rigid.useFullKinematicContacts = false;
        rigid.collisionDetectionMode = CollisionDetectionMode2D.Continuous;
        rigid.sleepMode = RigidbodySleepMode2D.NeverSleep;
        rigid.interpolation = RigidbodyInterpolation2D.Interpolate;
        rigid.constraints = RigidbodyConstraints2D.FreezeRotation;
        rigid.gravityScale = 0;

        contactFilter2D = new ContactFilter2D
        {
            useLayerMask = false,
            useTriggers = true,
            //layerMask = layerMask
        };
    }

    void Update()
    {
       
    }

    void FixedUpdate()
    {
        //rigid.position = rigid.position + velocity;

        velocity = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));

        Movement2(velocity * Time.deltaTime);
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


        //if (MyIntersects(m_Collider.bounds, Vector3.zero, m_Collider2.bounds, Vector3.zero))
        //{
        //    print("wawawa");
        //}
    }

    private void Movement2(Vector2 deltaPosition)
    {
        //if (deltaPosition == Vector2.zero)
        //    return;

        Vector2 updateDeltaPosition = Vector2.zero;

        float distance = deltaPosition.magnitude;
        Vector2 direction = deltaPosition.normalized;

        if (distance <= MIN_MOVE_DISTANCE)
            distance = MIN_MOVE_DISTANCE;

        raycastHit2DList = Tools.Instance.RigidBody2DCastF(rigid, direction, contactFilter2D, raycastHit2DList, distance);

        Vector2 finalDirection = direction;
        float finalDistance = distance;

        foreach (var hit2 in raycastHit2DList)
        {
            ColliderDistance2D cd2d = m_Collider.Distance(hit2.collider);
            if (MyIntersects2(m_Collider.bounds, Vector3.zero, hit2.collider.bounds, Vector3.zero) && IntersectsMenseki(m_Collider.bounds, hit2.collider.bounds) != Vector3.zero) // && m_Collider.bounds.Contains(hit2.point) //  && (m_Collider.bounds.Contains(cd2d.pointB) || hit2.collider.bounds.Contains(cd2d.pointA))
            {

                var hit = carcar(hit2);

                float moveDistance = hit.distance;

                Debug.DrawLine(hit.point, hit.point + hit.normal, Color.white);
                Debug.DrawLine(hit.point, hit.point + direction, Color.yellow);

                //if ((hit.normal.x == -1 && hit.normal.y == 0) || (direction.x == 0 && direction.y == 1))

                float projection = Vector2.Dot(hit.normal, direction);
                proj = projection;

                //if (projection >= 0)
                //    {
                //if ((hit.normal.x == -1 && hit.normal.y == 0) || (direction.x == 0 && direction.y == 1))
                //{
                //    ff = Vector2.Min(finalDirection * hit.distance, ff);
                //}
                //else
                //{
                //    ff = Vector2.Max(finalDirection * hit.distance, ff);
                //}

                

                if (projection < 0)
                {
                    moveDistance = hit.distance;
                }
                else
                {
                    Vector2 tangentDirection = new Vector2(hit.normal.y, -hit.normal.x);

                    float tangentDot = Vector2.Dot(tangentDirection, direction);

                    if (tangentDot < 0)
                    {
                        tangentDirection = -tangentDirection;
                        tangentDot = -tangentDot;
                    }

                    float tangentDistance = tangentDot * distance;

                    if (tangentDot != 0)
                    {
                        rigid.Cast(tangentDirection, contactFilter2D, tangentRaycastHit2DList, tangentDistance);

                        foreach (var tangentHit2 in tangentRaycastHit2DList)
                        {
                            ColliderDistance2D cd2d2 = m_Collider.Distance(hit2.collider);
                            if (MyIntersects(m_Collider.bounds, Vector3.zero, tangentHit2.collider.bounds, Vector3.zero) && IntersectsMenseki(m_Collider.bounds, tangentHit2.collider.bounds) != Vector3.zero) // && m_Collider.bounds.Contains(tangentHit2.point) //  && (m_Collider.bounds.Contains(cd2d.pointB) || tangentHit2.collider.bounds.Contains(cd2d.pointA))
                            {
                                var tangentHit = carcar(tangentHit2);

                                Debug.DrawLine(tangentHit.point, tangentHit.point + tangentDirection, Color.magenta);

                                if (Vector2.Dot(tangentHit.normal, tangentDirection) >= 0)
                                    continue;

                                if (tangentHit.distance < tangentDistance)
                                    tangentDistance = tangentHit.distance;
                            }
                        }

                        updateDeltaPosition += tangentDirection * tangentDistance;
                    }
                }

                if (moveDistance < finalDistance)
                {
                    finalDistance = moveDistance;
                }
            }
        }

        updateDeltaPosition += finalDirection * finalDistance;
        rigid.position += updateDeltaPosition;
    }

    private void Movement(Vector2 deltaPosition)
    {
        //if (deltaPosition == Vector2.zero)
        //    return;

        Vector2 updateDeltaPosition = Vector2.zero;

        float distance = deltaPosition.magnitude;
        Vector2 direction = deltaPosition.normalized;

        if (distance <= MIN_MOVE_DISTANCE)
            distance = MIN_MOVE_DISTANCE;

        raycastHit2DList = Tools.Instance.RigidBody2DCastF(rigid, direction, contactFilter2D, raycastHit2DList, distance);

        Vector2 finalDirection = direction;
        float finalDistance = distance;

        foreach (var hit2 in raycastHit2DList)
        {
            ColliderDistance2D cd2d = m_Collider.Distance(hit2.collider);
            if (MyIntersects(m_Collider.bounds, Vector3.zero, hit2.collider.bounds, Vector3.zero) && IntersectsMenseki(m_Collider.bounds, hit2.collider.bounds) != Vector3.zero) // && m_Collider.bounds.Contains(hit2.point) //  && (m_Collider.bounds.Contains(cd2d.pointB) || hit2.collider.bounds.Contains(cd2d.pointA))
            {
                var hit = carcar(hit2);

                float moveDistance = hit.distance;

                Debug.DrawLine(hit.point, hit.point + hit.normal, Color.white);
                Debug.DrawLine(hit.point, hit.point + direction, Color.yellow);

                //print(hit.distance + "," + hit2.distance);

                float projection = Vector2.Dot(hit.normal, direction);
                //print(projection);

                print(hit.normal + "," + direction + "," + projection + "," + distance);
                if (projection < 0)
                {
                    moveDistance = distance;
                }
                else
                {
                    Vector2 tangentDirection = new Vector2(hit.normal.y, -hit.normal.x);

                    float tangentDot = Vector2.Dot(tangentDirection, direction);

                    if (tangentDot < 0)
                    {
                        tangentDirection = -tangentDirection;
                        tangentDot = -tangentDot;
                    }

                    float tangentDistance = tangentDot * distance;

                    if (tangentDot != 0)
                    {
                        rigid.Cast(tangentDirection, contactFilter2D, tangentRaycastHit2DList, tangentDistance);

                        foreach (var tangentHit2 in tangentRaycastHit2DList)
                        {
                            ColliderDistance2D cd2d2 = m_Collider.Distance(hit2.collider);
                            if (MyIntersects(m_Collider.bounds, Vector3.zero, tangentHit2.collider.bounds, Vector3.zero) && IntersectsMenseki(m_Collider.bounds, tangentHit2.collider.bounds) != Vector3.zero) // && m_Collider.bounds.Contains(tangentHit2.point) //  && (m_Collider.bounds.Contains(cd2d.pointB) || tangentHit2.collider.bounds.Contains(cd2d.pointA))
                            {
                                var tangentHit = carcar(tangentHit2);

                                Debug.DrawLine(tangentHit.point, tangentHit.point + tangentDirection, Color.magenta);

                                if (Vector2.Dot(tangentHit.normal, tangentDirection) >= 0)
                                    continue;

                                if (tangentHit.distance < tangentDistance)
                                    tangentDistance = tangentHit.distance;
                            }
                        }

                        updateDeltaPosition += tangentDirection * tangentDistance;
                    }
                }

                if (moveDistance < finalDistance)
                {
                    finalDistance = moveDistance;
                }
            }
        }

        updateDeltaPosition += finalDirection * finalDistance;
        rigid.position += updateDeltaPosition;
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
        r.point = hit2.point;// + temp2;
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
        GUILayout.Label(proj.ToString());
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

        xxx = c - r;
        //var x = Mathf.Abs(c.x) <= r.x;
        //var y = Mathf.Abs(c.y) <= r.y;
        //var z = Mathf.Abs(c.z) <= r.z;

        print(xxx.x + "," + xxx.y);
        return xxx;

    }

    public static bool MyIntersects(Bounds lhs, Vector3 offsetl, Bounds rhs, Vector3 offsetr)
    {

        var c = (lhs.center + offsetl) - (rhs.center + offsetr);
        var r = lhs.extents + rhs.extents;

        var x = Mathf.Abs(c.x) < r.x;
        var y = Mathf.Abs(c.y) < r.y;

        return x & y;

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
}