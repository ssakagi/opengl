# coding: utf-8

# 必要ならrequireするライブラリは追加して下さい．
require 'opengl'
require 'glu'
require 'glut'
require 'cg/gfc'
require 'cg/camera'
require 'cg/bitmapfont'
require 'cg/mglutils'

WSIZE  = 800 # ウインドウサイズ


# カメラはz軸上の正の方向に配置され，原点をとらえている
INIT_THETA =  0.0  # カメラの初期位置
INIT_PHI   =  45.0  # カメラの初期位置
INIT_DIST  =  8.0  # カメラの原点からの距離の初期値
L_INIT_PHI = 45.0  # 光源の初期位置
L_INIT_PSI = 45.0  # 光源の初期位置
DZ = 0.125         # カメラの原点からの距離変更の単位
DT = 3             # 回転角単位

# テクスチャ座標自動生成の式を表すデータ(初期値)
INIT_S_PLANE = [0.0,0.5,0.0,0.0]  # s = 0.5y
INIT_T_PLANE = [0.0,0.0,-0.5,0.0] # t = -0.5z

SAMPLE_MATERIAL = [
  [0.6,0.6,0.6],  # AMBIENT(R,G,B)
  [0.8,0.8,0.8],  # DIFFUSE(R,G,B)
  [0.1,0.1,0.1],  # SPECULAR(R,G,B)
  64.0            # SHININESS
]

# Materialの項目定義
MATERIAL_ITEMS=[
  GL::AMBIENT,
  GL::DIFFUSE,
  GL::SPECULAR,
  GL::SHININESS
]

def generate_material(material_ingredient) # マテリアル配列を生成
  m_zero=material_ingredient
  m_one=material_ingredient.map{ |c| c*0.50}
  m_two=material_ingredient.map{ |c| c*0.75}
  return [m_zero,m_one,m_two,64.0]
end

def set_material(material)
  # 材質の設定
  MATERIAL_ITEMS.each_with_index do |item,i|
    GL.Material(GL::FRONT,item,material[i]) if material[i]
  end
end

# 状態変数
__camera = Camera.new(INIT_THETA,INIT_PHI,INIT_DIST)
__texname = nil # テクスチャオブジェクトを管理するための変数
__theta_arm = 0.0 # アームの経度
__phi_arm = 0.0 # アームの緯度
__theta_record = 0.0 # レコードの回転角
__anim_on = [false,false] # アニメーション制御フラグ

# 二次曲面オブジェクトの生成
quadric = GLU.NewQuadric()

# 二次曲面の描画スタイル
# quadric 二次曲面オブジェクト
# style   描画スタイル(GLU::POINT, GLU::LINE, GLU::FILL, GLU::SILHOUETTE)
GLU.QuadricDrawStyle(quadric,GLU::FILL)

# 二次曲面の法線処理モード
# quadric 二次曲面オブジェクト
# mode    法線モード(GLU::NONE, GLU::FLAT, GLU::SMOOTH)
GLU.QuadricNormals(quadric,GLU::SMOOTH)

def arm(quad,theta,phi)
  GL.PushMatrix()

  GL.Translate(1.5,1.5,0.0) # 所定の位置に移動

  # アーム本体
  GL.PushMatrix()
  GL.Translate(0.0,0.0,0.1)
  set_material(generate_material([0.2,0.2,0.2]))
  GLUT.SolidCube(0.2) # 留具
  GL.Rotate(theta,0.0,0.0,1.0) # 円盤方向に回転
  GL.Rotate(phi,0.0,-1.0,0.0)
  set_material(SAMPLE_MATERIAL)
  GLU.Cylinder(quad,0.05,0.05,1.0,12,12) # 棒
  GL.Translate(0.0,0.0,1.0)
  GL.Rotate(90,0.0,-1.0,0.0)
  set_material(generate_material([0.2,0.2,0.2]))
  GLUT.SolidCube(0.1)
  set_material(SAMPLE_MATERIAL)
  GLUT.SolidCone(0.05,0.1,12,12) # 針
  GL.PopMatrix()

  set_material(generate_material([0.2,0.2,0.2]))
  GLU.Disk(quad,0.0,0.2,30,30) # 付け根
  GL.Translate(0.0,0.0,0.01)
  set_material(SAMPLE_MATERIAL)
  GLU.Disk(quad,0.0,0.15,30,30)
  GL.Translate(0.0,0.0,-1.01)
  GLU.Cylinder(quad,0.2,0.2,1.0,30,30)

  GL.PopMatrix()
end

def box(quad)
  GL.PushMatrix()

  GL.Translate(0.0,0.0,-0.060)

  # 箱
  GL.PushMatrix()
  GL.Translate(0.0,0.0,-0.25)
  GL.Scale(1.0,1.0,0.1)
  GLUT.SolidCube(5.0)
  GL.PopMatrix()

  # レコード台
  set_material(generate_material([0.2,0.2,0.2]))
  GL.Disable(GL::TEXTURE_2D)
  GLU.Cylinder(quad,1.7,1.7,0.02,50,50)
  GL.Translate(0.0,0.0,0.02)
  GLU.Disk(quad,0.0,1.7,50,50)
  set_material(SAMPLE_MATERIAL)
  GL.Enable(GL::TEXTURE_2D)

  GL.PopMatrix()
end

#### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)
  # 光源の配置(平行光線)
  GL.Light(GL::LIGHT0,GL::POSITION,[1,1,1,0.0])

  # 点光源
  GL.Light(GL::LIGHT0,GL::POSITION,[0.0,0.0,1,2.0])
  GL.Light(GL::LIGHT0,GL::POSITION,[-0.5,-0.5,2,1.0])

  GL.BindTexture(GL::TEXTURE_2D,__texname[0])

  GL.TexGen(GL::S,GL::OBJECT_PLANE,INIT_S_PLANE)
  GL.TexGen(GL::T,GL::OBJECT_PLANE,INIT_T_PLANE)

  #GLUT.SolidTeapot(1.0)

  box(quadric)
  GL.Disable(GL::TEXTURE_2D)

  arm(quadric,__theta_arm,90+__phi_arm)

  # レコード

  GL.Enable(GL::TEXTURE_2D)
  GL.BindTexture(GL::TEXTURE_2D,__texname[1])
  GL.TexGen(GL::S,GL::OBJECT_PLANE,[0.5,0.0,0.0,0.0])
  GL.TexGen(GL::T,GL::OBJECT_PLANE,[0.0,0.0,-0.5,0.0])

  GL.PushMatrix()
  GL.Translate(0.0,0.0,-0.039)
  GL.Rotate(__theta_record,0.0,0.0,1.0)
  GLU.Disk(quadric,0.2,1.5,40,40)
  GL.PopMatrix()

  GLUT.SwapBuffers()
}

#### アイドルコールバック ########
idle = []
# 針を落とす
idle[0] = Proc.new {
  sleep(0.02)
  __phi_arm += 0.1
  if __phi_arm > 3.0
    GLUT.IdleFunc(idle[1])
    __anim_on[1] = true
  end
  GLUT.PostRedisplay()
}
# レコードを回す
idle[1] = Proc.new {
  sleep(0.02)
  __theta_record += 0.2
  GLUT.PostRedisplay()
}
# 針を上げる
idle[2] = Proc.new {
  sleep(0.02)
  __phi_arm -= 0.1
  if __phi_arm < 0.0
    GLUT.IdleFunc(nil)
    __anim_on[0] = false
  end
  GLUT.PostRedisplay()
}

#### キーボード入力コールバック ########
keyboard = Proc.new { |key,x,y|
  case key
  # [j],[J]: 経度の正方向/逆方向にカメラを移動する
  when 'j','J'
    __camera.move((key == 'j') ? DT : -DT,0,0)
  # [k],[K]: 緯度の正方向/逆方向にカメラを移動する
  when 'k','K'
    __camera.move(0,(key == 'k') ? DT : -DT,0)
  # [l],[L]:
  when 'l','L'
    __camera.move(0,0,(key == 'l') ? DT : -DT)
  # [z],[Z]: zoom in/out
  when 'z','Z'
    __camera.zoom((key == 'z') ? DZ : -DZ)
  # [r]: 初期状態に戻す
  when 'r'
    __camera.reset
  # [q],[ESC]: 終了する
  when 'q', "\x1b"
    exit 0
  # [t],[T]: アームを回転する
  when 't','T'
    if !__anim_on[0]
      __theta_arm += (key == 't') ? DT : -DT
      if __theta_arm < 0
        __theta_arm = 0
      elsif __theta_arm > 90
        __theta_arm = 90
      end
    end
  # [p]: レコードを再生する
  when 'p'
    if __theta_arm > 30 and __theta_arm < 60 and !__anim_on[0]
      __anim_on[0] = true
      GLUT.IdleFunc(idle[0])
    end
  # [s]: レコードを停止する
  when 's'
    if __anim_on[1]
      GLUT.IdleFunc(idle[2])
      __anim_on[1] = false
    end
  end

  GLUT.PostRedisplay()
}

#### ウインドウサイズ変更コールバック ########
reshape = Proc.new { |w,h|
  GL.Viewport(0,0,w,h)
  __camera.projection(w,h)
  GLUT.PostRedisplay()
}

### テクスチャの設定 ########
def setup_texture(inames)
  teximages=create_texture_images(inames) # テクスチャ画像の配列を構築する
  texname = GL.GenTextures(2)             # テクスチャオブジェクトのIDの確保(2面分)

  # 立方体の各面に貼るテクスチャの設定
  2.times do |i|
    GL.BindTexture(GL::TEXTURE_2D,texname[i])

    ## テクスチャ画像生成
    img,width,height = teximages[i]
    GL.TexImage2D(GL::TEXTURE_2D,0,GL::RGB,width,height,0,GL::RGB,
		  GL::UNSIGNED_BYTE,img)

    ## テクスチャ座標に対するパラメタ指定
    GL.TexParameter(GL::TEXTURE_2D,GL::TEXTURE_WRAP_S,GL::REPEAT)
    GL.TexParameter(GL::TEXTURE_2D,GL::TEXTURE_WRAP_T,GL::REPEAT)

    ## ピクセルに対応するテクスチャの値の決定
    GL.TexParameter(GL::TEXTURE_2D,GL::TEXTURE_MAG_FILTER,GL::NEAREST)
    GL.TexParameter(GL::TEXTURE_2D,GL::TEXTURE_MIN_FILTER,GL::NEAREST)
  end

  ## テクスチャの環境(表示方法)の指定(GL::REPLACE;テクスチャ値をそのまま使う)
  GL.TexEnv(GL::TEXTURE_ENV,GL::TEXTURE_ENV_MODE,GL::REPLACE)

  ## テクスチャ座標自動生成方法の指定→オブジェクトを基準とする
  GL.TexGen(GL::S,GL::TEXTURE_GEN_MODE,GL::OBJECT_LINEAR)
  GL.TexGen(GL::T,GL::TEXTURE_GEN_MODE,GL::OBJECT_LINEAR)

  GL.Enable(GL::TEXTURE_2D)    # 2次元テクスチャを使用可能にする
  GL.Enable(GL::TEXTURE_GEN_S) # s方向のテクスチャ座標の自動生成を有効にする
  GL.Enable(GL::TEXTURE_GEN_T) # t方向のテクスチャ座標の自動生成を有効にする

  texname
end

## テクスチャ画像の読み込み
# inames: テクスチャ画像ファイル名の配列
# 読みこんだ画像のデータ配列を返す[[pixels_0,width_0,height_0],...]
def create_texture_images(inames)
  images=[]
  inames.each do |iname|
    g = Gfc.load(iname)
    width,height = g.size
    images.push([g.get_bytes,width,height])
  end
  images
end

# シェーディングの設定
def init_shading
  # 光源の環境光，拡散，鏡面成分の設定
  GL.Light(GL::LIGHT0,GL::AMBIENT, [0.4,0.4,0.4])
  GL.Light(GL::LIGHT0,GL::DIFFUSE, [1.0,1.0,1.0])
  GL.Light(GL::LIGHT0,GL::SPECULAR,[1.0,1.0,1.0])

  # シェーディング処理ON,光源(No.0)ON
  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::LIGHT0)
  GL.Enable(GL::NORMALIZE) # 法線の自動単位ベクトル化
end


##############################################
# main

if ARGV.size < 2
  STDERR.puts 'テクスチャ画像を2枚指定して下さい'
  exit 1
end
# 画像ファイルの配列を作る
ifiles=ARGV[0,2]

##############################################
GLUT.Init()
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE|GLUT::DEPTH)
GLUT.InitWindowSize(WSIZE,WSIZE)
GLUT.CreateWindow('Record Player') # ウインドウタイトル(適切に設定すること)
GLUT.DisplayFunc(display)
GLUT.KeyboardFunc(keyboard)
GLUT.ReshapeFunc(reshape)
GL.Enable(GL::DEPTH_TEST)
__texname=setup_texture(ifiles) # テクスチャの構築
init_shading()  # 光源の設定
__camera.set    # カメラを配置する
GL.ClearColor(0.0,0.0,0.0,1.0)
GLUT.MainLoop()
