using UnityEngine;
using UnityEngine.Rendering.Universal;

public class MyRendererFeature : ScriptableRendererFeature
{
    private MyRenderPass _renderPass;
    public Material _renderPassMaterial=null;
    public override void Create()
    {
        _renderPass = new MyRenderPass(_renderPassMaterial);
       
    }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (_renderPassMaterial == null)
        {
            Debug.LogWarningFormat("Missing Material");
            return;
        }
        renderer.EnqueuePass(_renderPass);
    }
}
