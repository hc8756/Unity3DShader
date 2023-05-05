using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class MyRenderPass : ScriptableRenderPass
{
    private RenderTargetIdentifier source;
    private RenderTargetIdentifier destination;
    int destinationId;
    int temporaryRTId = Shader.PropertyToID("_TempRT");
    private Material blitMat = null;

    public MyRenderPass(Material mat)
    {
        blitMat = mat;
        renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
    }
    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        var renderer = renderingData.cameraData.renderer;
        source = renderer.cameraColorTarget; 
        destinationId = temporaryRTId;
        RenderTextureDescriptor blitTargetDescriptor = renderingData.cameraData.cameraTargetDescriptor;
        blitTargetDescriptor.depthBufferBits = 0;
        cmd.GetTemporaryRT(destinationId, blitTargetDescriptor, FilterMode.Point);
        destination = new RenderTargetIdentifier(destinationId);
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        //store commands to execute in buffer
        CommandBuffer cmd = CommandBufferPool.Get("_PassCommandBuffer");
        Blit(cmd, source, destination, blitMat);
        Blit(cmd, destination, source);
        //execute commands in buffer
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }


}
