#!/bin/bash

# Copyright (C) 2014 - Badr BADRI 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

function libsdl2_get_deps {
  local a=0
}

function libsdl2_build {
  local host=$1
  pushDir $WORK/src

  lazy_download "libsdl2.tar.gz" "https://www.libsdl.org/release/SDL2-2.0.4.tar.gz"
  lazy_extract "libsdl2.tar.gz" 
  mkgit "libsdl2"

  pushDir "libsdl2"
  libsdl2_patches
  popDir

  autoconf_build $host "libsdl2"

  popDir
}

function libsdl2_patches {
  local patchFile=$scriptDir/patches/libsdl2_01_D3D11Declarations.diff
  cat << 'EOF' > $patchFile
diff --git a/src/render/direct3d11/SDL_render_d3d11.c b/src/render/direct3d11/SDL_render_d3d11.c
index a48eace..71d2b4c 100644
--- a/src/render/direct3d11/SDL_render_d3d11.c
+++ b/src/render/direct3d11/SDL_render_d3d11.c
@@ -50,6 +50,8 @@ extern ISwapChainBackgroundPanelNative * WINRT_GlobalSwapChainBackgroundPanelNat
 
 #endif  /* __WINRT__ */
 
+#define SDL_DEBUG_STRINGIFY_ARG(str)       #str
+#define SDL_DEBUG(str) SDL_DEBUG_STRINGIFY_ARG(__FUNCTION__) str
 
 #define SAFE_RELEASE(X) if ((X)) { IUnknown_Release(SDL_static_cast(IUnknown*, X)); X = NULL; }
 
@@ -137,13 +139,27 @@ typedef struct
 
 
 /* Defined here so we don't have to include uuid.lib */
+#ifndef __IDXGIFactory2_INTERFACE_DEFINED__
 static const GUID IID_IDXGIFactory2 = { 0x50c83a1c, 0xe072, 0x4c48, { 0x87, 0xb0, 0x36, 0x30, 0xfa, 0x36, 0xa6, 0xd0 } };
+#endif
+#ifndef __IDXGIDevice1_INTERFACE_DEFINED__
 static const GUID IID_IDXGIDevice1 = { 0x77db970f, 0x6276, 0x48ba, { 0xba, 0x28, 0x07, 0x01, 0x43, 0xb4, 0x39, 0x2c } };
+#endif
+#ifndef __IDXGIDevice3_INTERFACE_DEFINED__
 static const GUID IID_IDXGIDevice3 = { 0x6007896c, 0x3244, 0x4afd, { 0xbf, 0x18, 0xa6, 0xd3, 0xbe, 0xda, 0x50, 0x23 } };
+#endif
+#ifndef __ID3D11Texture2D_INTERFACE_DEFINED__
 static const GUID IID_ID3D11Texture2D = { 0x6f15aaf2, 0xd208, 0x4e89, { 0x9a, 0xb4, 0x48, 0x95, 0x35, 0xd3, 0x4f, 0x9c } };
+#endif
+#ifndef __ID3D11Device1_INTERFACE_DEFINED__
 static const GUID IID_ID3D11Device1 = { 0xa04bfb29, 0x08ef, 0x43d6, { 0xa4, 0x9c, 0xa9, 0xbd, 0xbd, 0xcb, 0xe6, 0x86 } };
+#endif
+#ifndef __ID3D11DeviceContext1_INTERFACE_DEFINED__
 static const GUID IID_ID3D11DeviceContext1 = { 0xbb2c6faa, 0xb5fb, 0x4082, { 0x8e, 0x6b, 0x38, 0x8b, 0x8c, 0xfa, 0x90, 0xe1 } };
+#endif
+#ifndef __ID3D11Debug_INTERFACE_DEFINED__
 static const GUID IID_ID3D11Debug = { 0x79cf2233, 0x7536, 0x4948, { 0x9d, 0x36, 0x1e, 0x46, 0x92, 0xdc, 0x57, 0x60 } };
+#endif
 
 /* Direct3D 11.x shaders
 
@@ -961,7 +977,7 @@ D3D11_CreateBlendMode(SDL_Renderer * renderer,
     blendDesc.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;
     result = ID3D11Device_CreateBlendState(data->d3dDevice, &blendDesc, blendStateOutput);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateBlendState", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG(", ID3D11Device1::CreateBlendState"), result);
         return result;
     }
 
@@ -1043,14 +1059,14 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
 
     result = CreateDXGIFactoryFunc(&IID_IDXGIFactory2, &data->dxgiFactory);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", CreateDXGIFactory", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG(", CreateDXGIFactory"), result);
         goto done;
     }
 
     /* FIXME: Should we use the default adapter? */
     result = IDXGIFactory2_EnumAdapters(data->dxgiFactory, 0, &data->dxgiAdapter);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", D3D11CreateDevice", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG(", D3D11CreateDevice"), result);
         goto done;
     }
 
@@ -1079,25 +1095,25 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
         &d3dContext /* Returns the device immediate context. */
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", D3D11CreateDevice", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", D3D11CreateDevice"), result);
         goto done;
     }
 
     result = ID3D11Device_QueryInterface(d3dDevice, &IID_ID3D11Device1, &data->d3dDevice);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device to ID3D11Device1", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device to ID3D11Device1"), result);
         goto done;
     }
 
     result = ID3D11DeviceContext_QueryInterface(d3dContext, &IID_ID3D11DeviceContext1, &data->d3dContext);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11DeviceContext to ID3D11DeviceContext1", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11DeviceContext to ID3D11DeviceContext1"), result);
         goto done;
     }
 
     result = ID3D11Device_QueryInterface(d3dDevice, &IID_IDXGIDevice1, &dxgiDevice);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device to IDXGIDevice1", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device to IDXGIDevice1"), result);
         goto done;
     }
 
@@ -1106,7 +1122,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
      */
     result = IDXGIDevice1_SetMaximumFrameLatency(dxgiDevice, 1);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", IDXGIDevice1::SetMaximumFrameLatency", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", IDXGIDevice1::SetMaximumFrameLatency"), result);
         goto done;
     }
 
@@ -1135,7 +1151,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
             break;
 
         default:
-            SDL_SetError(__FUNCTION__ ", Unexpected feature level: %d", data->featureLevel);
+            SDL_SetError(SDL_DEBUG( ", Unexpected feature level: %d"), data->featureLevel);
             result = E_FAIL;
             goto done;
     }
@@ -1148,7 +1164,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
         &data->vertexShader
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateVertexShader", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateVertexShader"), result);
         goto done;
     }
 
@@ -1161,7 +1177,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
         &data->inputLayout
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateInputLayout", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateInputLayout"), result);
         goto done;
     }
 
@@ -1173,7 +1189,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
         &data->colorPixelShader
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreatePixelShader ['color' shader]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreatePixelShader ['color' shader]"), result);
         goto done;
     }
 
@@ -1184,7 +1200,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
         &data->texturePixelShader
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreatePixelShader ['textures' shader]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreatePixelShader ['textures' shader]"), result);
         goto done;
     }
 
@@ -1195,7 +1211,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
         &data->yuvPixelShader
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreatePixelShader ['yuv' shader]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreatePixelShader ['yuv' shader]"), result);
         goto done;
     }
 
@@ -1210,7 +1226,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
         &data->vertexShaderConstants
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateBuffer [vertex shader constants]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateBuffer [vertex shader constants]"), result);
         goto done;
     }
 
@@ -1230,7 +1246,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
         &data->nearestPixelSampler
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateSamplerState [nearest-pixel filter]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateSamplerState [nearest-pixel filter]"), result);
         goto done;
     }
 
@@ -1240,7 +1256,7 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
         &data->linearSampler
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateSamplerState [linear filter]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateSamplerState [linear filter]"), result);
         goto done;
     }
 
@@ -1258,14 +1274,14 @@ D3D11_CreateDeviceResources(SDL_Renderer * renderer)
     rasterDesc.SlopeScaledDepthBias = 0.0f;
     result = ID3D11Device_CreateRasterizerState(data->d3dDevice, &rasterDesc, &data->mainRasterizer);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateRasterizerState [main rasterizer]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateRasterizerState [main rasterizer]"), result);
         goto done;
     }
 
     rasterDesc.ScissorEnable = TRUE;
     result = ID3D11Device_CreateRasterizerState(data->d3dDevice, &rasterDesc, &data->clippedRasterizer);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateRasterizerState [clipped rasterizer]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateRasterizerState [clipped rasterizer]"), result);
         goto done;
     }
 
@@ -1444,7 +1460,7 @@ D3D11_CreateSwapChain(SDL_Renderer * renderer, int w, int h)
             &data->swapChain
             );
         if (FAILED(result)) {
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", IDXGIFactory2::CreateSwapChainForCoreWindow", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", IDXGIFactory2::CreateSwapChainForCoreWindow"), result);
             goto done;
         }
     } else if (usingXAML) {
@@ -1454,18 +1470,18 @@ D3D11_CreateSwapChain(SDL_Renderer * renderer, int w, int h)
             NULL,
             &data->swapChain);
         if (FAILED(result)) {
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", IDXGIFactory2::CreateSwapChainForComposition", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", IDXGIFactory2::CreateSwapChainForComposition"), result);
             goto done;
         }
 
 #if WINAPI_FAMILY == WINAPI_FAMILY_APP
         result = ISwapChainBackgroundPanelNative_SetSwapChain(WINRT_GlobalSwapChainBackgroundPanelNative, (IDXGISwapChain *) data->swapChain);
         if (FAILED(result)) {
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", ISwapChainBackgroundPanelNative::SetSwapChain", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ISwapChainBackgroundPanelNative::SetSwapChain"), result);
             goto done;
         }
 #else
-        SDL_SetError(__FUNCTION__ ", XAML support is not yet available for Windows Phone");
+        SDL_SetError(SDL_DEBUG( ", XAML support is not yet available for Windows Phone"));
         result = E_FAIL;
         goto done;
 #endif
@@ -1484,13 +1500,13 @@ D3D11_CreateSwapChain(SDL_Renderer * renderer, int w, int h)
             &data->swapChain
             );
         if (FAILED(result)) {
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", IDXGIFactory2::CreateSwapChainForHwnd", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", IDXGIFactory2::CreateSwapChainForHwnd"), result);
             goto done;
         }
 
         IDXGIFactory_MakeWindowAssociation(data->dxgiFactory, windowinfo.info.win.window, DXGI_MWA_NO_WINDOW_CHANGES);
 #else
-        SDL_SetError(__FUNCTION__", Unable to find something to attach a swap chain to");
+        SDL_SetError(SDL_DEBUG(", Unable to find something to attach a swap chain to"));
         goto done;
 #endif  /* ifdef __WIN32__ / else */
     }
@@ -1545,7 +1561,7 @@ D3D11_CreateWindowSizeDependentResources(SDL_Renderer * renderer)
              */
             goto done;
         } else if (FAILED(result)) {
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", IDXGISwapChain::ResizeBuffers", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", IDXGISwapChain::ResizeBuffers"), result);
             goto done;
         }
 #endif
@@ -1576,7 +1592,7 @@ D3D11_CreateWindowSizeDependentResources(SDL_Renderer * renderer)
     if (data->swapEffect == DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL) {
         result = IDXGISwapChain1_SetRotation(data->swapChain, data->rotation);
         if (FAILED(result)) {
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", IDXGISwapChain1::SetRotation", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", IDXGISwapChain1::SetRotation"), result);
             goto done;
         }
     }
@@ -1588,7 +1604,7 @@ D3D11_CreateWindowSizeDependentResources(SDL_Renderer * renderer)
         &backBuffer
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", IDXGISwapChain::GetBuffer [back-buffer]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", IDXGISwapChain::GetBuffer [back-buffer]"), result);
         goto done;
     }
 
@@ -1599,7 +1615,7 @@ D3D11_CreateWindowSizeDependentResources(SDL_Renderer * renderer)
         &data->mainRenderTargetView
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device::CreateRenderTargetView", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device::CreateRenderTargetView"), result);
         goto done;
     }
 
@@ -1663,7 +1679,7 @@ D3D11_Trim(SDL_Renderer * renderer)
 
     result = ID3D11Device_QueryInterface(data->d3dDevice, &IID_IDXGIDevice3, &dxgiDevice);
     if (FAILED(result)) {
-        //WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device to IDXGIDevice3", result);
+        //WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device to IDXGIDevice3"), result);
         return;
     }
 
@@ -1747,7 +1763,7 @@ D3D11_CreateTexture(SDL_Renderer * renderer, SDL_Texture * texture)
         );
     if (FAILED(result)) {
         D3D11_DestroyTexture(renderer, texture);
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateTexture2D", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateTexture2D"), result);
         return -1;
     }
 
@@ -1765,7 +1781,7 @@ D3D11_CreateTexture(SDL_Renderer * renderer, SDL_Texture * texture)
             );
         if (FAILED(result)) {
             D3D11_DestroyTexture(renderer, texture);
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateTexture2D", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateTexture2D"), result);
             return -1;
         }
 
@@ -1776,7 +1792,7 @@ D3D11_CreateTexture(SDL_Renderer * renderer, SDL_Texture * texture)
             );
         if (FAILED(result)) {
             D3D11_DestroyTexture(renderer, texture);
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateTexture2D", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateTexture2D"), result);
             return -1;
         }
     }
@@ -1792,7 +1808,7 @@ D3D11_CreateTexture(SDL_Renderer * renderer, SDL_Texture * texture)
         );
     if (FAILED(result)) {
         D3D11_DestroyTexture(renderer, texture);
-        WIN_SetErrorFromHRESULT(__FUNCTION__ "ID3D11Device1::CreateShaderResourceView", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( "ID3D11Device1::CreateShaderResourceView"), result);
         return -1;
     }
 
@@ -1804,7 +1820,7 @@ D3D11_CreateTexture(SDL_Renderer * renderer, SDL_Texture * texture)
             );
         if (FAILED(result)) {
             D3D11_DestroyTexture(renderer, texture);
-            WIN_SetErrorFromHRESULT(__FUNCTION__ "ID3D11Device1::CreateShaderResourceView", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( "ID3D11Device1::CreateShaderResourceView"), result);
             return -1;
         }
         result = ID3D11Device_CreateShaderResourceView(rendererData->d3dDevice,
@@ -1814,7 +1830,7 @@ D3D11_CreateTexture(SDL_Renderer * renderer, SDL_Texture * texture)
             );
         if (FAILED(result)) {
             D3D11_DestroyTexture(renderer, texture);
-            WIN_SetErrorFromHRESULT(__FUNCTION__ "ID3D11Device1::CreateShaderResourceView", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( "ID3D11Device1::CreateShaderResourceView"), result);
             return -1;
         }
     }
@@ -1831,7 +1847,7 @@ D3D11_CreateTexture(SDL_Renderer * renderer, SDL_Texture * texture)
             &textureData->mainTextureRenderTargetView);
         if (FAILED(result)) {
             D3D11_DestroyTexture(renderer, texture);
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateRenderTargetView", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateRenderTargetView"), result);
             return -1;
         }
     }
@@ -1887,7 +1903,7 @@ D3D11_UpdateTextureInternal(D3D11_RenderData *rendererData, ID3D11Texture2D *tex
         NULL,
         &stagingTexture);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateTexture2D [create staging texture]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateTexture2D [create staging texture]"), result);
         return -1;
     }
 
@@ -1900,7 +1916,7 @@ D3D11_UpdateTextureInternal(D3D11_RenderData *rendererData, ID3D11Texture2D *tex
         &textureMemory
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11DeviceContext1::Map [map staging texture]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11DeviceContext1::Map [map staging texture]"), result);
         SAFE_RELEASE(stagingTexture);
         return -1;
     }
@@ -2062,7 +2078,7 @@ D3D11_LockTexture(SDL_Renderer * renderer, SDL_Texture * texture,
         NULL,
         &textureData->stagingTexture);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateTexture2D [create staging texture]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateTexture2D [create staging texture]"), result);
         return -1;
     }
 
@@ -2075,7 +2091,7 @@ D3D11_LockTexture(SDL_Renderer * renderer, SDL_Texture * texture,
         &textureMemory
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11DeviceContext1::Map [map staging texture]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11DeviceContext1::Map [map staging texture]"), result);
         SAFE_RELEASE(textureData->stagingTexture);
         return -1;
     }
@@ -2359,7 +2375,7 @@ D3D11_UpdateVertexBuffer(SDL_Renderer *renderer,
             &mappedResource
             );
         if (FAILED(result)) {
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11DeviceContext1::Map [vertex buffer]", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11DeviceContext1::Map [vertex buffer]"), result);
             return -1;
         }
         SDL_memcpy(mappedResource.pData, vertexData, dataSizeInBytes);
@@ -2383,7 +2399,7 @@ D3D11_UpdateVertexBuffer(SDL_Renderer *renderer,
             &rendererData->vertexBuffer
             );
         if (FAILED(result)) {
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateBuffer [vertex buffer]", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateBuffer [vertex buffer]"), result);
             return -1;
         }
 
@@ -2853,7 +2869,7 @@ D3D11_RenderReadPixels(SDL_Renderer * renderer, const SDL_Rect * rect,
         &backBuffer
         );
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", IDXGISwapChain1::GetBuffer [get back buffer]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", IDXGISwapChain1::GetBuffer [get back buffer]"), result);
         goto done;
     }
 
@@ -2870,7 +2886,7 @@ D3D11_RenderReadPixels(SDL_Renderer * renderer, const SDL_Rect * rect,
         NULL,
         &stagingTexture);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11Device1::CreateTexture2D [create staging texture]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11Device1::CreateTexture2D [create staging texture]"), result);
         goto done;
     }
 
@@ -2902,7 +2918,7 @@ D3D11_RenderReadPixels(SDL_Renderer * renderer, const SDL_Rect * rect,
         0,
         &textureMemory);
     if (FAILED(result)) {
-        WIN_SetErrorFromHRESULT(__FUNCTION__ ", ID3D11DeviceContext1::Map [map staging texture]", result);
+        WIN_SetErrorFromHRESULT(SDL_DEBUG( ", ID3D11DeviceContext1::Map [map staging texture]"), result);
         goto done;
     }
 
@@ -2921,7 +2937,7 @@ D3D11_RenderReadPixels(SDL_Renderer * renderer, const SDL_Rect * rect,
          * Get the error message, and attach some extra data to it.
          */
         char errorMessage[1024];
-        SDL_snprintf(errorMessage, sizeof(errorMessage), __FUNCTION__ ", Convert Pixels failed: %s", SDL_GetError());
+        SDL_snprintf(errorMessage, sizeof(errorMessage), SDL_DEBUG( ", Convert Pixels failed: %s"), SDL_GetError());
         SDL_SetError("%s", errorMessage);
         goto done;
     }
@@ -2991,7 +3007,7 @@ D3D11_RenderPresent(SDL_Renderer * renderer)
             /* We probably went through a fullscreen <-> windowed transition */
             D3D11_CreateWindowSizeDependentResources(renderer);
         } else {
-            WIN_SetErrorFromHRESULT(__FUNCTION__ ", IDXGISwapChain::Present", result);
+            WIN_SetErrorFromHRESULT(SDL_DEBUG( ", IDXGISwapChain::Present"), result);
         }
     }
 }
EOF

  applyPatch $patchFile
}
