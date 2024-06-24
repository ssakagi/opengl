# coding: utf-8

require 'opengl'
require 'glu'
require 'glut'
require 'cg/mglutils'

WSIZE=600
T=Math::PI/3 # 単位角

__theta=Math::PI/4
__phi=0
__anim_on=false

def hexagram(cx,cy,r,theta)

  d=0.05 # 幅
  s=2*r*(1.0-d)/3 # 小三角形の中心と原点の距離
  t=r*(1.0-4*d)/3 # 小三角形の半径
  u=r*(1.0-2*d)/Math.sqrt(3) # 正六角形の半径

  GL.Begin(GL::TRIANGLES)
  GL.Color(0.67,0.47,0.02)
  2.times do |i|
    3.times do |j|
      GL.Vertex(cx+r*Math.cos(theta+(2*j+i)*T),cy+r*Math.sin(theta+(2*j+i)*T))
    end
  end

  GL.Color(0.0,0.0,0.0)
  6.times do |i|
    3.times do |j|
      GL.Vertex(
        cx+s*Math.cos(theta+i*T)+t*Math.cos(theta+(2*j+i%2)*T),
        cy+s*Math.sin(theta+i*T)+t*Math.sin(theta+(2*j+i%2)*T)
        )
    end
  end
  GL.End()

  GL.Begin(GL::POLYGON)
  6.times do |k|
    GL.Vertex(cx+u*Math.cos(theta+T/2+k*T),cy+u*Math.sin(theta+T/2+k*T))
  end
  GL.End()

end

def sun_and_moon(cx,cy,r0,r,d,theta,phi)

  # 軌道
  GL.Color(0.67,0.47,0.02)
  MGLUtils.disc([cx,cy],r0+d/2.0)
  GL.Color(0.0,0.0,0.0)
  MGLUtils.disc([cx,cy],r0-d/2.0) # d:軌道幅

  GL.Color(0.67,0.47,0.02)
  # 太陽
  cx_s,cy_s=cx+r0*Math.cos(theta),cy+r0*Math.sin(theta)
  MGLUtils.disc([cx_s,cy_s],r)
  GL.Begin(GL::TRIANGLES)

  4.times do |k|
    GL.Vertex(
      cx_s+3*(1+Math.sqrt(3)*Math.tan(T/8))*r*Math.cos(phi+k*Math::PI/2)/2,
      cy_s+3*(1+Math.sqrt(3)*Math.tan(T/8))*r*Math.sin(phi+k*Math::PI/2)/2
      )
    GL.Vertex(
      cx_s+3*r*Math.cos(phi+k*Math::PI/2+T/8)/(2*Math.cos(T/8)),
      cy_s+3*r*Math.sin(phi+k*Math::PI/2+T/8)/(2*Math.cos(T/8))
      )
    GL.Vertex(
      cx_s+3*r*Math.cos(phi+k*Math::PI/2-T/8)/(2*Math.cos(T/8)),
      cy_s+3*r*Math.sin(phi+k*Math::PI/2-T/8)/(2*Math.cos(T/8))
      )
  end

  GL.End()

  # 月
  cx_m,cy_m=cx-r0*Math.cos(theta),cy-r0*Math.sin(theta)
  MGLUtils.disc([cx_m,cy_m],r)
  GL.Color(0.0,0.0,0.0)
  MGLUtils.disc([cx_m+r*Math.cos(phi+3*Math::PI/4)/2.0,cy_m+r*Math.sin(phi+3*Math::PI/4)/2.0],r/2.0)

end

### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT) # 画面のクリア

  # 描画する内容を記述する
  sun_and_moon(0.0,0.0,0.8,0.1,0.01,__theta,__phi)
  GL.Color(0.67,0.47,0.02)
  MGLUtils.disc([0.0,0.0],0.5+0.005)
  GL.Color(0.0,0.0,0.0)
  MGLUtils.disc([0.0,0.0],0.5-0.005)
  hexagram(0.0,0.0,0.5,T/2)

  GLUT.SwapBuffers()
}

### アイドルコールバック ######
idle = Proc.new{
  sleep(0.1)
  __theta+=0.02*Math::PI
  __phi+=0.05*Math::PI
  GLUT.PostRedisplay()
}

### キーボード入力コールバック ########
keyboard = Proc.new { |key,x,y|
  # [r]でアニメーション開始/停止
  if key == 'r'
    if __anim_on
      GLUT.IdleFunc(nil)
      __anim_on = false
    else
      GLUT.IdleFunc(idle)
      __anim_on = true
    end
  end
  # [q]でプログラムを終了
  if key == 'q'
    exit 0
  end
}

#### マウス入力コールバック ########
mouse = Proc.new { |button,state,x,y|

  # マウスボタンを押したときの動作を記述する

}

##############################################
# main
##############################################
GLUT.Init()
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE)
GLUT.InitWindowSize(WSIZE,WSIZE) # ウインドウサイズ(適切に設定すること)
GLUT.CreateWindow('Title')       # ウインドウタイトル(適切に設定すること)
GLUT.DisplayFunc(display)        # 描画コールバックの登録
GLUT.KeyboardFunc(keyboard)      # キーボード入力コールバックの登録
GLUT.MouseFunc(mouse)            # マウス入力コールバックの登録
GL.ClearColor(0.0,0.0,0.0,1.0)   # 背景色(R,G,B,A) Aの値は気にしなくてよい．
GLUT.MainLoop()
