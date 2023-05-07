using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Manager : MonoBehaviour
{
    public Toggle toonOn;
    public Toggle anaglyphOn;
    public Slider anaglyphOffset;
    public Material toonMat;
    public Material anaglyphMat;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        anaglyphMat.SetFloat("_Offset", anaglyphOffset.value);
    }
}
