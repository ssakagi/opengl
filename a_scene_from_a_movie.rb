# coding: utf-8

require 'opengl'
require 'glu'
require 'glut'
require 'cg/mglutils'

WSIZE=600

N=21 # __binaryの行(列)数
G=150 # グリッド線本数

idle=[] # 各種アニメーション用コールバックを格納
__display=[] # 各種アニメーション用描画の表示フラグ配列

__interfere=false # 阻害インタラクション用フラグ

# kuramon_eating用状態変数(位置)
__kuramon_x=0
__kuramon_y=0
i=0 # kuramon_eating用カウンタ

__binary=Array.new(N*N){ [false,rand(2)]} # 二進数配列(乱数と表示フラグのセットの配列)
hello=[[true,"h"],[true,"e"],[true,"l"],[true,"l"],[true,"o"]] # hello配列

def digital(array,n) # デジタル表示メソッド(nは行(列)数)
  array.each_with_index do |a,i|

    if a[0] # 表示フラグがonのとき

      w=0.2/n # セグメント幅
      d=0.6/n # セグメント間隔

      x1=-d/2 # 中央セグメントの第一頂点(以下反時計周りに指定)
      x1-=1.0-1.0/n-(i%n)*2.0/n
      y1=w/2
      y1+=1.0-1.0/n-(i/n)*2.0/n
      x2=x1-w/2
      y2=y1-w/2
      x3=x1
      y3=y1-w
      x4=x3+d
      y4=y3
      x5=x2+d+w
      y5=y2
      x6=x1+d
      y6=y1

      x7=x1 # 左上セグメントの第一頂点(以下反時計周りに指定)
      y7=y1+d
      x8=x2
      y8=y2+d+w
      x9=x1-w
      y9=y1+d
      x10=x1-w
      y10=y1
      x11=x2
      y11=y2
      x12=x1
      y12=y1

      # 中央
      if ["h","e"].include?(a[1])
        GL.Color(0.0,0.0,0.0)
        GL.Rect(x1,y1,x4,y4)
        GL.Begin(GL::TRIANGLES)
        GL.Vertex(x1,y1)
        GL.Vertex(x2,y2)
        GL.Vertex(x3,y3)
        GL.Vertex(x4,y4)
        GL.Vertex(x5,y5)
        GL.Vertex(x6,y6)
        GL.End()
      end

      # 左上
      if a[1]!=1
        a[1]==0 ? GL.Color(1.0,0.5,0.0) : GL.Color(0.0,0.0,0.0)
        GL.Rect(x9,y9,x12,y12)
        GL.Begin(GL::TRIANGLES)
        GL.Vertex(x7,y7)
        GL.Vertex(x8,y8)
        GL.Vertex(x9,y9)
        GL.Vertex(x10,y10)
        GL.Vertex(x11,y11)
        GL.Vertex(x12,y12)
        GL.End()
      end

      # 真上
      if [0,"e","o"].include?(a[1])
        a[1]==0 ? GL.Color(1.0,0.5,0.0) : GL.Color(0.0,0.0,0.0)
        GL.Rect(x1,y1+d+w,x4,y4+d+w)
        GL.Begin(GL::TRIANGLES)
        GL.Vertex(x1,y1+d+w)
        GL.Vertex(x2,y2+d+w)
        GL.Vertex(x3,y3+d+w)
        GL.Vertex(x4,y4+d+w)
        GL.Vertex(x5,y5+d+w)
        GL.Vertex(x6,y6+d+w)
        GL.End()
      end

      # 右上
      if [0,1,"h","o"].include?(a[1])
        [0,1].include?(a[1]) ? GL.Color(1.0,0.5,0.0) : GL.Color(0.0,0.0,0.0)
        GL.Rect(x9+d+w,y9,x12+d+w,y12)
        GL.Begin(GL::TRIANGLES)
        GL.Vertex(x7+d+w,y7)
        GL.Vertex(x8+d+w,y8)
        GL.Vertex(x9+d+w,y9)
        GL.Vertex(x10+d+w,y10)
        GL.Vertex(x11+d+w,y11)
        GL.Vertex(x12+d+w,y12)
        GL.End()
      end

      # 左下
      if a[1]!=1
        a[1]==0 ? GL.Color(1.0,0.5,0.0) : GL.Color(0.0,0.0,0.0)
        GL.Rect(x9,y9-d-w,x12,y12-d-w)
        GL.Begin(GL::TRIANGLES)
        GL.Vertex(x7,y7-d-w)
        GL.Vertex(x8,y8-d-w)
        GL.Vertex(x9,y9-d-w)
        GL.Vertex(x10,y10-d-w)
        GL.Vertex(x11,y11-d-w)
        GL.Vertex(x12,y12-d-w)
        GL.End()
      end

      # 真下
      if [0,"e","l","o"].include?(a[1])
        a[1]==0 ? GL.Color(1.0,0.5,0.0) : GL.Color(0.0,0.0,0.0)
        GL.Rect(x1,y1-d-w,x4,y4-d-w)
        GL.Begin(GL::TRIANGLES)
        GL.Vertex(x1,y1-d-w)
        GL.Vertex(x2,y2-d-w)
        GL.Vertex(x3,y3-d-w)
        GL.Vertex(x4,y4-d-w)
        GL.Vertex(x5,y5-d-w)
        GL.Vertex(x6,y6-d-w)
        GL.End()
      end

      # 右下
      if [0,1,"h","o"].include?(a[1])
        [0,1].include?(a[1]) ? GL.Color(1.0,0.5,0.0) : GL.Color(0.0,0.0,0.0)
        GL.Rect(x9+d+w,y9-d-w,x12+d+w,y12-d-w)
        GL.Begin(GL::TRIANGLES)
        GL.Vertex(x7+d+w,y7-d-w)
        GL.Vertex(x8+d+w,y8-d-w)
        GL.Vertex(x9+d+w,y9-d-w)
        GL.Vertex(x10+d+w,y10-d-w)
        GL.Vertex(x11+d+w,y11-d-w)
        GL.Vertex(x12+d+w,y12-d-w)
        GL.End()
      end

    end

  end
end

def kuramon_appear(cx,cy) # (cx,cy)は中心位置

  # フレーム
  GL.Color(0.0,0.0,0.0)
  MGLUtils.disc([cx,cy],0.4)

  GL.Begin(GL::TRIANGLES)

  GL.Vertex(cx-0.34,cy+0.2) # 左耳
  GL.Vertex(cx-0.13,cy+0.37)
  GL.Vertex(cx-0.31,cy+0.38)

  GL.Vertex(cx+0.34,cy+0.2) # 右耳
  GL.Vertex(cx+0.13,cy+0.37)
  GL.Vertex(cx+0.31,cy+0.38)

  GL.Vertex(cx-0.37,cy-0.12) # 左足
  GL.Vertex(cx-0.11,cy-0.35)
  GL.Vertex(cx-0.42,cy-0.37)

  GL.Vertex(cx+0.37,cy-0.12) # 右足
  GL.Vertex(cx+0.11,cy-0.35)
  GL.Vertex(cx+0.42,cy-0.37)

  GL.Vertex(cx-0.32,cy-0.28) # 前足
  GL.Vertex(cx+0.32,cy-0.28)
  GL.Vertex(cx,cy-0.46)

  GL.End()

  GL.Color(0.6,0.6,1.0)
  MGLUtils.disc([cx,cy],0.39)

  GL.Begin(GL::TRIANGLES)

  GL.Vertex(cx-0.33,cy+0.2) # 左耳
  GL.Vertex(cx-0.13,cy+0.36)
  GL.Vertex(cx-0.3,cy+0.37)

  GL.Vertex(cx+0.33,cy+0.2) # 右耳
  GL.Vertex(cx+0.13,cy+0.36)
  GL.Vertex(cx+0.3,cy+0.37)

  GL.Vertex(cx-0.36,cy-0.13) # 左足
  GL.Vertex(cx-0.1,cy-0.34)
  GL.Vertex(cx-0.41,cy-0.36)

  GL.Vertex(cx+0.36,cy-0.13) # 右足
  GL.Vertex(cx+0.1,cy-0.34)
  GL.Vertex(cx+0.41,cy-0.36)

  GL.Vertex(cx-0.31,cy-0.27) # 前足
  GL.Vertex(cx+0.31,cy-0.27)
  GL.Vertex(cx,cy-0.45)

  GL.End()

  GL.Color(0.0,0.0,0.0)
  MGLUtils.disc([cx,cy+0.05],0.18)

  # 目尻
  GL.Begin(GL::TRIANGLES)

  GL.Vertex(cx-0.17,cy+0.1)
  GL.Vertex(cx-0.17,cy)
  GL.Vertex(cx-0.23,cy+0.05)

  GL.Vertex(cx+0.17,cy+0.1)
  GL.Vertex(cx+0.17,cy)
  GL.Vertex(cx+0.23,cy+0.05)

  GL.End()

  GL.Color(1.0,0.25,0.0)
  MGLUtils.disc([cx,cy+0.05],0.15)

  # 瞳孔
  GL.Color(0.0,0.0,0.0)
  MGLUtils.disc([cx,cy+0.05],0.1)

  # ハイライト
  GL.Color(1.0,1.0,1.0)
  MGLUtils.disc([cx-0.08,cy+0.12],0.05)
  MGLUtils.disc([cx+0.09,cy-0.03],0.035)

end

def kuramon_eating(cx,cy,n)

  m=2.0/n # 縮小率

  # フレーム
  GL.Color(0.0,0.0,0.0)
  MGLUtils.disc([cx,cy],0.5*m)

  GL.Begin(GL::TRIANGLES)

  GL.Vertex(cx-0.34*m,cy+0.2*m) # 左耳
  GL.Vertex(cx-0.13*m,cy+0.37*m)
  GL.Vertex(cx-0.31*m,cy+0.38*m)

  GL.Vertex(cx+0.34*m,cy+0.2*m) # 右耳
  GL.Vertex(cx+0.13*m,cy+0.37*m)
  GL.Vertex(cx+0.31*m,cy+0.38*m)

  GL.Vertex(cx-0.37*m,cy-0.12*m) # 左足
  GL.Vertex(cx-0.11*m,cy-0.35*m)
  GL.Vertex(cx-0.42*m,cy-0.37*m)

  GL.Vertex(cx+0.37*m,cy-0.12*m) # 右足
  GL.Vertex(cx+0.11*m,cy-0.35*m)
  GL.Vertex(cx+0.42*m,cy-0.37*m)

  GL.Vertex(cx-0.32*m,cy-0.28*m) # 前足
  GL.Vertex(cx+0.32*m,cy-0.28*m)
  GL.Vertex(cx,cy-0.46*m)

  GL.End()

  GL.Color(0.6,0.6,1.0)
  MGLUtils.disc([cx,cy],0.39*m)

  GL.Begin(GL::TRIANGLES)

  GL.Vertex(cx-0.33*m,cy+0.2*m) # 左耳
  GL.Vertex(cx-0.13*m,cy+0.36*m)
  GL.Vertex(cx-0.3*m,cy+0.37*m)

  GL.Vertex(cx+0.33*m,cy+0.2*m) # 右耳
  GL.Vertex(cx+0.13*m,cy+0.36*m)
  GL.Vertex(cx+0.3*m,cy+0.37*m)

  GL.Vertex(cx-0.36*m,cy-0.13*m) # 左足
  GL.Vertex(cx-0.1*m,cy-0.34*m)
  GL.Vertex(cx-0.41*m,cy-0.36*m)

  GL.Vertex(cx+0.36*m,cy-0.13*m) # 右足
  GL.Vertex(cx+0.1*m,cy-0.34*m)
  GL.Vertex(cx+0.41*m,cy-0.36*m)

  GL.Vertex(cx-0.31*m,cy-0.27*m) # 前足
  GL.Vertex(cx+0.31*m,cy-0.27*m)
  GL.Vertex(cx,cy-0.45*m)

  GL.End()

  GL.Color(0.0,0.0,0.0)
  MGLUtils.disc([cx+0.1*m,cy+0.05*m],0.18*m)

  # 目尻
  GL.Begin(GL::TRIANGLES)

  GL.Vertex(cx-0.07*m,cy+0.1*m)
  GL.Vertex(cx-0.07*m,cy)
  GL.Vertex(cx-0.13*m,cy+0.05*m)

  GL.Vertex(cx+0.18*m,cy+0.1*m)
  GL.Vertex(cx+0.18*m,cy)
  GL.Vertex(cx+0.24*m,cy+0.05*m)

  GL.End()

  GL.Color(1.0,0.25,0.0)
  MGLUtils.disc([cx+0.1*m,cy+0.05*m],0.15*m)

  # 瞳孔
  GL.Color(0.0,0.0,0.0)
  MGLUtils.disc([cx+0.1*m,cy+0.05*m],0.1*m)

  # ハイライト
  GL.Color(1.0,1.0,1.0)
  MGLUtils.disc([cx+0.02*m,cy+0.12*m],0.05*m)
  MGLUtils.disc([cx+0.19*m,cy-0.03*m],0.035*m)

end

### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT) # 画面のクリア

  # 描画する内容を記述する

  # グリッド線
  if __display[0]
    GL.Color(0.0,0.25,0.25)
    (G+1).times do |k|
      GL.Begin(GL::LINES)
      GL.Vertex(2.0*k/G-1.0,1.0)
      GL.Vertex(2.0*k/G-1.0,-1.0)
      GL.Vertex(-1.0,1.0-2.0*k/G)
      GL.Vertex(1.0,1.0-2.0*k/G)
      GL.End()
    end
  end

  digital(__binary,N) # 二進数表示

  kuramon_appear(0.0,-0.3) if __display[1]

  # 吹き出しとhello
  if __display[2]
    GL.Color(0.0,0.0,0.25)
    GL.Rect(-1.0,1.0,1.0,0.6)
    GL.Color(1.0,1.0,1.0)
    GL.Rect(-0.98,0.98,0.98,0.62)
    GL.Begin(GL::POLYGON)
    GL.Vertex(0.0,0.3)
    GL.Vertex(0.1,0.62)
    GL.Vertex(-0.1,0.62)
    GL.End()
    digital(hello,5)
  end

  kuramon_eating(__kuramon_x,__kuramon_y,N) if __display[3]

  GLUT.SwapBuffers()
}

###アイドルコールバック########

# グリッド表示後待機アニメーション
idle[0] = Proc.new {
  sleep(2.0)
  __binary[0][0]=true
  GLUT.IdleFunc(idle[1])
}

# 二進数配列生成(正確には表示)アニメーション
idle[1] = Proc.new {
  sleep(0.01)
  __binary.each_with_index do |b,i|
    b[1]=rand(2) # 生成的表現(各bitがランダムに変化し続ける)
    if __binary[i][0]!=__binary[i+1][0]
      __binary[i+1][0]=true # 表示bit追加
      break # 即1step終了
    end
  end
  GLUT.PostRedisplay()
  GLUT.IdleFunc(idle[2]) if __binary[N*N-1][0] # 表示完了
}

# 待機+クラモン登場アニメーション
idle[2] = Proc.new {
  sleep(3.0)
  __display[1]=true
  GLUT.PostRedisplay()
  GLUT.IdleFunc(idle[3])
}

# 待機+挨拶アニメーション
idle[3] = Proc.new {
  sleep(3.0)
  __display[2]=true
  GLUT.PostRedisplay()
  GLUT.IdleFunc(idle[4])
}

# 挨拶後待機アニメーション
idle[4] = Proc.new {

  # 2回目の処理(idle[5]の準備)
  if !__display[1]
    __display[3]=true
    GLUT.IdleFunc(idle[5])
  end

  # 1,2回目の処理
  sleep(3.0)
  __display[1]=false
  __display[2]=false
  GLUT.PostRedisplay()

}

# データ侵食アニメーション
idle[5] = Proc.new {

  sleep(0.01)

  # 阻害インタラクションによる硬直
  if __interfere
    sleep(0.2)
    __interfere=false
  end

  # 変位(移動量はbit間隔の半分)
  __kuramon_x=-1.0+(i%(2*N))*(1.0/N)
  __kuramon_y=1.0-1.0/N-(i/(2*N))*(2.0/N)

  # 侵食
  __binary[(i/2)%(N*N)][0]=false if i.even?

  i+=1 # カウンタ更新

  # 終了処理
  if !__display[3]
    sleep(2.0)
    GLUT.IdleFunc(nil)
    i=0 # カウンタ初期化
    __display[0]=false # グリッド及び開始インタラクション制御フラグoff
  end

  __display[3]=false if !__binary[N*N-1][0] # 侵食完了

  GLUT.PostRedisplay()

}

### キーボード入力コールバック ########
keyboard = Proc.new { |key,x,y|

  # [s]でアニメーション開始/停止
  if key == 's' and !__display[0] # __display[0]のみ特殊用途有り
    sleep(0.5) # ラグ表現
    __display[0]=true # グリッド用フラグ兼インタラクション制御用フラグ(一連のアニメーション中の開始インタラクションを不可にする)
    GLUT.PostRedisplay()
    GLUT.IdleFunc(idle[0])
  end

  # [q]でプログラムを終了
  if key == 'q'
    exit 0
  end

}

#### マウス入力コールバック ########
mouse = Proc.new { |button,state,x,y|

  # マウスボタンを押したときの動作を記述する
  __interfere=true if state==GLUT::DOWN and __display[3]

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
