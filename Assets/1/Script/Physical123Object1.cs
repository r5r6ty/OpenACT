using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[RequireComponent(typeof(Collider2D))]
public class Physical123Object1 : MonoBehaviour
{
    private const float MIN_MOVE_DISTANCE = 0.001f;

    //private new Collider2D collider2D;
    private new Rigidbody2D rigidbody2D;
    private ContactFilter2D contactFilter2D;
    private List<RaycastHit2D> raycastHit2DList = new List<RaycastHit2D>();
    private List<RaycastHit2D> tangentRaycastHit2DList = new List<RaycastHit2D>();

    public LayerMask layerMask;
    [HideInInspector]
    public Vector2 velocity;

    BoxCollider2D m_Collider;
    void Start()
    {
        m_Collider = gameObject.GetComponent<BoxCollider2D>();
        //collider2D = GetComponent<Collider2D>();
        rigidbody2D = GetComponent<Rigidbody2D>();

        if (rigidbody2D == null)
            rigidbody2D = gameObject.AddComponent<Rigidbody2D>();

        //rigidbody2D.hideFlags = HideFlags.NotEditable;
        rigidbody2D.bodyType = RigidbodyType2D.Kinematic;
        //rigidbody2D.simulated = true;
        rigidbody2D.useFullKinematicContacts = false;
        rigidbody2D.collisionDetectionMode = CollisionDetectionMode2D.Continuous;
        rigidbody2D.sleepMode = RigidbodySleepMode2D.NeverSleep;
        rigidbody2D.interpolation = RigidbodyInterpolation2D.Interpolate;
        rigidbody2D.constraints = RigidbodyConstraints2D.FreezeRotation;
        rigidbody2D.gravityScale = 0;

        contactFilter2D = new ContactFilter2D
        {
            useLayerMask = false,
            useTriggers = false,
            //layerMask = layerMask
        };
    }

    private void OnValidate()
    {
        contactFilter2D.layerMask = layerMask;
    }

    private void Update()
    {
        velocity = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
    }

    private void FixedUpdate()
    {
        Movement(velocity * Time.deltaTime);
    }

    private void Movement(Vector2 deltaPosition)
    {
        if (deltaPosition == Vector2.zero)
            return;

        Vector2 updateDeltaPosition = Vector2.zero;

        float distance = deltaPosition.magnitude;
        Vector2 direction = deltaPosition.normalized;

        if (distance <= MIN_MOVE_DISTANCE)
            distance = MIN_MOVE_DISTANCE;

        raycastHit2DList = Tools.Instance.RigidBody2DCastF(rigidbody2D, direction, contactFilter2D, raycastHit2DList, distance);

        Vector2 finalDirection = direction;
        float finalDistance = distance;

        List<Collider2D> a = new List<Collider2D>();
        m_Collider.OverlapCollider(contactFilter2D, a);
        for (int i = 0; i < a.Count; i++)
        {
            Collider2D aaa = a[i];
            if (m_Collider.bounds.Intersects(aaa.bounds)) // && m_Collider.bounds.Contains(hit2.point) //  && (m_Collider.bounds.Contains(cd2d.pointB) || hit2.collider.bounds.Contains(cd2d.pointA))
            {
                Vector3 menseki = IntersectsMenseki(m_Collider.bounds, aaa.bounds);
                //print(menseki);
                if (menseki != Vector3.zero)
                {
                    ColliderDistance2D cd2d = m_Collider.Distance(aaa);
                    Vector2 hitnormal = -cd2d.normal;
                    Vector2 temp = menseki * hitnormal;
                    float hitdistance = -temp.magnitude;

                    float moveDistance = hitdistance;

                    //Debug.DrawLine(hit.point, hit.point + hit.normal, Color.white);
                    //Debug.DrawLine(hit.point, hit.point + direction, Color.yellow);

                    float projection = Vector2.Dot(hitnormal, direction);

                    //print(hitnormal + "," + direction + "," + projection + "," + distance);
                    if (projection >= 0)
                    {
                        moveDistance = distance;
                    }
                    else
                    {
                        Vector2 tangentDirection = new Vector2(hitnormal.y, -hitnormal.x);

                        float tangentDot = Vector2.Dot(tangentDirection, direction);

                        if (tangentDot < 0)
                        {
                            tangentDirection = -tangentDirection;
                            tangentDot = -tangentDot;
                        }

                        float tangentDistance = tangentDot * distance;

                        if (tangentDot != 0)
                        {
                            List<Collider2D> b = new List<Collider2D>();
                            m_Collider.OverlapCollider(contactFilter2D, b);
                            for (int j = 0; j < b.Count; j++)
                            {
                                Collider2D bbb = b[j];
                                if (m_Collider.bounds.Intersects(bbb.bounds)) // && m_Collider.bounds.Contains(hit2.point) //  && (m_Collider.bounds.Contains(cd2d.pointB) || hit2.collider.bounds.Contains(cd2d.pointA))
                                {
                                    Vector3 menseki2 = IntersectsMenseki(m_Collider.bounds, bbb.bounds);
                                    //print(menseki);
                                    if (menseki2 != Vector3.zero)
                                    {
                                        ColliderDistance2D cd2d2 = m_Collider.Distance(bbb);
                                        Vector2 hitnormal2 = -cd2d2.normal;
                                        Vector2 temp2 = menseki2 * hitnormal2;
                                        float hitdistance2 = -temp2.magnitude;


                                        //Debug.DrawLine(tangentHit.point, tangentHit.point + tangentDirection, Color.magenta);

                                        if (Vector2.Dot(hitnormal2, tangentDirection) >= 0)
                                            continue;

                                        if (hitdistance2 < tangentDistance)
                                            tangentDistance = hitdistance2;
                                    }
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
        }

        updateDeltaPosition += finalDirection * finalDistance;
        rigidbody2D.position += updateDeltaPosition;
    }

    public Vector3 IntersectsMenseki(Bounds lhs, Bounds rhs)
    {

        var c = lhs.center - rhs.center;
        var r = lhs.extents + rhs.extents;
        //ccc = c;
        //rrr = r;

        var xxx = r - new Vector3(Mathf.Abs(c.x), Mathf.Abs(c.y), Mathf.Abs(c.z));
        return xxx;

    }
}