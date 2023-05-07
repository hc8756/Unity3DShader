using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Manager : MonoBehaviour
{
    //public Toggle toonOn;
    public Toggle anaglyphOn;
    public Slider anaglyphOffset;
    public Material anaglyphMat;
    public Toggle outlineOn;
    public Material outlineMat;
    
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {   
        if (anaglyphOn.isOn) { anaglyphMat.SetInt("_EffectOn", 1);}
        else { anaglyphMat.SetInt("_EffectOn", 0);}
        anaglyphMat.SetFloat("_Offset", anaglyphOffset.value);

        if (outlineOn.isOn) { outlineMat.SetInt("_EffectOn", 1); }
        else { outlineMat.SetInt("_EffectOn", 0); }

        
        
    }
}
