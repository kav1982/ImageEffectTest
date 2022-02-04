﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class DepthOfFieldEddect : MonoBehaviour
{
    [HideInInspector] public Shader dofShader;

    [NonSerialized] private Material dofMaterial;

    const int circleofConfusionPass = 0;

    [Range(0.1f, 100f)] public float focusDistance = 10f;

    [Range(0.1f, 10f)] public float focusRange = 3f;
    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (dofMaterial == null)
        {
            dofMaterial = new Material(dofShader);
            dofMaterial.hideFlags = HideFlags.HideAndDontSave;
        }
        
        dofMaterial.SetFloat("_FocusDistance", focusDistance);
        dofMaterial.SetFloat("_FocusRange", focusRange);
        Graphics.Blit(source, destination, dofMaterial, circleofConfusionPass);
    }
    
}
