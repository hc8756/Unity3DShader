using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class AnaglyphFeature : ScriptableRendererFeature
{
    private AnaglyphPass anaglyphPass;
    public Material anaglyphMat = null;
    public override void Create()
    {
        anaglyphPass = new AnaglyphPass(anaglyphMat);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (anaglyphMat == null) {
            Debug.LogWarningFormat("Missing Material");
            return;
        }
        renderer.EnqueuePass(anaglyphPass);
    }

    public class AnaglyphPass : ScriptableRenderPass {
        private RenderTargetIdentifier source;
        private RenderTargetIdentifier destination;
        int destinationId;
        int temporaryRTId = Shader.PropertyToID("_TempRT");
        private Material blitMat = null; 

        public AnaglyphPass(Material mat) 
        {
            blitMat = mat;
            renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var renderer = renderingData.cameraData.renderer;
            source = renderer.cameraColorTarget;destinationId = temporaryRTId;
            RenderTextureDescriptor blitTargetDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            blitTargetDescriptor.depthBufferBits = 0;
            cmd.GetTemporaryRT(destinationId, blitTargetDescriptor, FilterMode.Point);
            destination = new RenderTargetIdentifier(destinationId);
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            //store commands to execute in buffer
            CommandBuffer cmd = CommandBufferPool.Get("_AnaglyphPass");
            //post processing code goes here
            //blit function documentation: https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@7.1/api/UnityEngine.Rendering.Universal.ScriptableRenderPass.html#UnityEngine_Rendering_Universal_ScriptableRenderPass_Blit_CommandBuffer_RenderTargetIdentifier_RenderTargetIdentifier_Material_System_Int32_
            //first blit destination and second blit source is a temporary rendering target


            Blit(cmd, source, destination, blitMat); 
            Blit(cmd, destination, source);
            //execute commands in buffer
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

    }


}
