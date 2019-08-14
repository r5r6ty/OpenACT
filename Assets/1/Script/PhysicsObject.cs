using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PhysicsObject : MonoBehaviour {

    public float minGroundNormalY = .65f;
    public float gravityModifier = 1f;

    protected Vector2 targetVelocity;
    protected bool grounded;
    protected Vector2 groundNormal;
    protected Rigidbody2D rb2d;
    protected Vector2 velocity;
    protected ContactFilter2D contactFilter;
    protected RaycastHit2D[] hitBuffer = new RaycastHit2D[16];
    protected List<RaycastHit2D> hitBufferList = new List<RaycastHit2D> (16);


    protected const float minMoveDistance = 0.001f;
    protected const float shellRadius = 0.11f;

    void OnEnable()
    {
        rb2d = GetComponent<Rigidbody2D> ();
    }

    void Start () 
    {
        contactFilter.useTriggers = true;
        //contactFilter.SetLayerMask (Physics2D.GetLayerCollisionMask (gameObject.layer));
        //contactFilter.useLayerMask = true;
    }

    void Update () 
    {
        targetVelocity = Vector2.zero;
        ComputeVelocity (); 
    }

    protected virtual void ComputeVelocity()
    {
        targetVelocity += new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
    }

    void FixedUpdate()
    {
        velocity += gravityModifier * Physics2D.gravity * Time.deltaTime;
        velocity.x = targetVelocity.x;

        grounded = false;

        Vector2 deltaPosition = velocity * Time.deltaTime;

        Vector2 moveAlongGround = new Vector2 (groundNormal.y, -groundNormal.x);

        Vector2 move = moveAlongGround * deltaPosition.x;

        Movement (move, false);

        move = Vector2.up * deltaPosition.y;

        Movement (move, true);
    }

    void Movement(Vector2 move, bool yMovement)
    {
        float distance = move.magnitude;

        if (distance > minMoveDistance) 
        {
            int count = rb2d.Cast (move, contactFilter, hitBuffer, distance + shellRadius);
            hitBufferList.Clear ();
            for (int i = 0; i < count; i++) {
                hitBufferList.Add (hitBuffer [i]);
            }

            for (int i = 0; i < hitBufferList.Count; i++) 
            {
                Vector2 currentNormal = hitBufferList [i].normal;
                if (currentNormal.y > minGroundNormalY) 
                {
                    grounded = true;
                    if (yMovement) 
                    {
                        groundNormal = currentNormal;
                        currentNormal.x = 0;
                    }
                }
                //List<Collider2D> ccc = new List<Collider2D>();
                //rb2d.GetAttachedColliders(ccc);

                //for (int j = 0; j < ccc.Count; j++)
                {
                    //if (ccc[j].bounds.Intersects(hitBufferList[i].collider.bounds))
                    {
                        float projection = Vector2.Dot(velocity, currentNormal);
                        if (projection < 0)
                        {
                            velocity = velocity - projection * currentNormal;
                        }

                        //RaycastHit2D cccccc = carcar(ccc[j], hitBufferList[i]);

                        float modifiedDistance = hitBufferList[i].distance + shellRadius; //  + cccccc.distance
                        distance = modifiedDistance < distance ? modifiedDistance : distance;
                    }

                }


            }


        }

        rb2d.position = rb2d.position + move.normalized * distance;
    }


    RaycastHit2D carcar(Collider2D m_Collider, RaycastHit2D hit2)
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
        r.normal = hit2.normal;
        return r;
    }
    public Vector3 Intersects(Bounds lhs, Bounds rhs)
    {

        var c = lhs.center - rhs.center;
        var r = lhs.extents + rhs.extents;
        //ccc = c;
        //rrr = r;

        var xxx = c - r;
        //var x = Mathf.Abs(c.x) <= r.x;
        //var y = Mathf.Abs(c.y) <= r.y;
        //var z = Mathf.Abs(c.z) <= r.z;

        return xxx;

    }

}
