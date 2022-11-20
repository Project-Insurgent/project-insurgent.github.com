#==============================================================================#
#                                  DPPT MAP v2.1                               #
#                               (by S.A.Somersault)                            #
#==============================================================================#
# A script that implements a gen 4 style map!                                  #
# IMPORTANT: NEEDS SUSc v5.1+ in order to work properly                        #
#==============================================================================#
# Future features:
# -Fly destination mode
#==============================================================================#
# Usage: pbDPPTMap                                                             #
#==============================================================================#
#==============================================================================#
#                                TOP SCREEN MODULE                             #
#==============================================================================#
class SinnohMapTopScreen < SMSpriteWrapper
  include SinnohMap
  def initialize(mod,viewport,ctrl)
    super({:NAME=>TOWNMAP_NAME,:PATH=>PATH,:CTRL=>ctrl,:VIEWPORT=>viewport})
    @mod = mod
    @counter = 0
    @cursorFrame = 0
  end
  
  def init
    addObj("bg",TOWNMAP_NAME)
    addObj("Loc",TOWNMAP_NAME)

    #visited location icons:
    locs = @mod.getLocs
    traversedIds = {}
    addObj("mapIcons","mapIconsSel")
    @objectsList["mapIcons"].clear
    for mapName in locs.keys #undefined keys 4 nil class
      for mapId in locs[mapName]["Maps"].keys
        map = locs[mapName]["Maps"][mapId]
        if map["Icon"] != -1 && !traversedIds[map["Pos"]]
          traversedIds[map["Pos"]] = true          
          @objectsList["mapIcons"].addObj(mapId,"mapIconsSel",(map["Pos"][0]+X_MARGIN)*TILE_SIDE,(map["Pos"][1]+Y_MARGIN)*TILE_SIDE )
          @objectsList["mapIcons"].list[mapId].set_src_rect(
            TILE_SIDE*2*(map["Icon"]%4), TILE_SIDE*2*(map["Icon"]/4),
            TILE_SIDE*2, TILE_SIDE*2
          )
          @objectsList["mapIcons"].list[mapId].visible=$PokemonGlobal.visitedMaps[mapId]
        end
      end
    end
    
    #player icon:
    _x=(@mod.getPlayerPos[0]+X_MARGIN)*TILE_SIDE
    _y=(@mod.getPlayerPos[1]+Y_MARGIN)*TILE_SIDE
    addObj("PlayerIcon",$Trainer.male? ? ICON_NAME_M : ICON_NAME_F,_x,_y)
    @objectsList["PlayerIcon"].ox = 10
    @objectsList["PlayerIcon"].oy = 10
    
    #cursor:
    pos = @mod.getCursorPos
    addObj("Cursor")
    @objectsList["Cursor"].set_src_rect(0,0,CURSOR_WIDTH,CURSOR_HEIGHT)
    @objectsList["Cursor"].ox = 10
    @objectsList["Cursor"].oy = 10
  end
  
  def activate
    @sprite.visible = true
    for i in @objectsList.keys; @objectsList[i].visible = true unless i == "mapIcons"; end
    for i in @objectsList["mapIcons"].list.keys; @objectsList["mapIcons"].list[i].visible = $PokemonGlobal.visitedMaps[i.to_i]; end

    pos = @mod.getCursorPos
    @objectsList["Cursor"].x = (pos[0]+X_MARGIN)*TILE_SIDE*zoom_x
    @objectsList["Cursor"].y = (pos[1]+Y_MARGIN)*TILE_SIDE*zoom_y
  end
  
  def update
    updateText
    updateCursor
    @counter = (@counter+1)%CS_FRAME_TIME
  end
  
  def updateText
    @objectsList["Loc"].clear
    @objectsList["Loc"].setSystemFont
    @objectsList["Loc"].drawText([[_INTL(@mod.getCurLocId),self.x+LOC_NAME_X,self.y+LOC_NAME_Y,2,LOC_NAME_FG_COLOR,LOC_NAME_BG_COLOR]])
  end
  
  def updateCursor
    pos = @mod.getCursorPos
    cursor = @objectsList["Cursor"]
    cursor.x = (pos[0]+X_MARGIN)*TILE_SIDE*zoom_x
    cursor.y = (pos[1]+Y_MARGIN)*TILE_SIDE*zoom_y
    
    cursor.set_src_rect(@cursorFrame*CURSOR_WIDTH,0,CURSOR_WIDTH,CURSOR_HEIGHT)
    @cursorFrame = (@cursorFrame+1)%CURSOR_FRAMES if @counter == 0
  end
end
#==============================================================================#
#==============================================================================#
#                             BOTTOM SCREEN MODULE                             #
#==============================================================================#
class SinnohMapBtmScreen < SMSpriteWrapper
  include SinnohMap
  def initialize(mod,viewport,ctrl)
    super({:NAME=>"BtmScreen",:PATH=>PATH,:CTRL=>ctrl,:VIEWPORT=>viewport})#Sprite.new(viewport),"BtmScreen",PATH,0,0,ctrl,viewport)
    @mod = mod
    @counter = 0
    @cursorFrame = 0
    @detailMode = false
    @curLocName = ""
  end
  
  def detailMode=(val); @detailMode = val; end;
  def detailMode; return @detailMode; end
  
  def activate; 
    self.visible = true
    update();
  end
  
  def init
    addObj("detMap","BtmScreen")
    detMap = @objectsList["detMap"]
    
    #button:
    addObj("Button","LowScBtn",192,162)
    btn = @objectsList["Button"]
    btn.set_src_rect(0,0,btn.width/5,btn.height)
    btn.visible=MULTI_SCREEN
    
    #detail map background:
    detMap.addObj("det_Bg","lowerscreenShowMode")
    detMap.list["det_Bg"].ox=detMap.list["det_Bg"].width/4
    detMap.list["det_Bg"].oy=detMap.list["det_Bg"].height/4
    
    #map Tag:
    detMap.addObj("maptag","Tag",TAG_X,TAG_Y)
    detMap.list["maptag"].setSystemFont
    lText=[[_INTL(TAG_TEXT),TAG_TEXT_X,TAG_TEXT_Y,2,TAG_TEXT_FG_COLOR,TAG_TEXT_BG_COLOR]]
    detMap.list["maptag"].drawText(lText)
    
    #desc Panel:
    detMap.addObj("descPanel","descPanel",DESC_PANEL_X,DESC_PANEL_Y)
    detMap.list["descPanel"].addObj("minimap","Empty",MINIMAP_X,MINIMAP_Y,SIGNPOSTSPATH)
    detMap.list["descPanel"].addObj("descTitle","descPanel",0,10)
    detMap.list["descPanel"].list["descTitle"].clear
    detMap.list["descPanel"].list["descTitle"].setSystemFont
    
    #desc texts:
    detMap.addObj("descTexts","BtmScreen")
    detMap.list["descTexts"].clear
=begin
    for key in $DESC_ARRAY.keys
      detMap.list["descTexts"].addObj(key,0,0,"BtmScreen")
      detMap.list["descTexts"].list[key].clear
      detMap.list["descTexts"].list[key].setSystemFont
      detMap.list["descTexts"].list[key].drawFTextEx([
        10,120,500,_INTL($DESC_ARRAY[key]),
        Color.new(245,245,245),Color.new(215,215,215)
      ])
    end
=end
    detMap.visible = false
  end
  
  def update
    @objectsList["detMap"].visible = @detailMode
    if @detailMode
      placeBtmMap()
      showDesc()
    end
  end

  def placeBtmMap
    pos = @mod.getCursorPos
    detMap = @objectsList["detMap"]

    #X COMPONENT:
    if pos[0] < (MAP_WIDTH_TILES-X_MARGIN-6) && pos[0] > X_MARGIN+6; 
      posX = pos[0]
    else
      posX = pos[0] <= X_MARGIN+6 ? X_MARGIN+6 : (MAP_WIDTH_TILES-X_MARGIN-6)
    end
    detMap.list["det_Bg"].x=(@sprite.x+width-32*posX)*@sprite.zoom_x
  
    #Y COMPONENT:
    if pos[1] < (MAP_HEIGHT_TILES-Y_MARGIN-5) && pos[1] > Y_MARGIN+6
      posY = pos[1]
    else
      posY = pos[1] <= Y_MARGIN+6 ? Y_MARGIN+6 : (MAP_HEIGHT_TILES-Y_MARGIN-5)
    end
    detMap.list["det_Bg"].y=(@sprite.y+height-32*(posY))*@sprite.zoom_y
  end
  
  def showDesc()
    detMap = @objectsList["detMap"]
    locId = @mod.getCurLocId
    path = SIGNPOSTSPATH+locId.to_s
    detMap.list["descPanel"].visible = locId && (!path.include?("Route") || SHOW_DESC_ON_ROUTES)

    if detMap.list["descPanel"].visible && (@curLocName != locId)
      xOffset = FileTest.image_exist?(path) ? 96 : 10
      @curLocName = locId
      dText = @mod.getDesc #currently unused
      lText=[[_INTL(locId),104+xOffset,0,2,Color.new(245,245,245),Color.new(215,215,215)]]
      detMap.list["descPanel"].list["descTitle"].clear
      detMap.list["descPanel"].list["descTitle"].drawText(lText)

      #detMap.list["descTexts"].list[@curLocName].visible = false
      #detMap.list["descTexts"].list[locId].visible       = true
      detMap.list["descPanel"].list["minimap"].bitmap=Bitmap.new(locId != "" && xOffset == 96 ? path : SIGNPOSTSPATH+"Empty")
    end
  end
end
#==============================================================================#
#==============================================================================#
#                               SINNOH MAP VIEW                                #
#==============================================================================#
class SinnohMapView < SMModuleView
  include SinnohMap
  def initialize(mod,ctrl=nil)
    super({:PATH=>PATH,:MOD=>mod,:CTRL=>ctrl,:ID=>ID})
    initBlackScreens(true)
    for panel in @panels.values; panel.clear; end

    #init top screen:
    @panels[:MAIN_PANEL] = SinnohMapTopScreen.new(@mod,@panels[:MAIN_PANEL].viewport,self)
    @panels[:MAIN_PANEL].init
    #@panels[:MAIN_PANEL].fitSpriteInViewport(@panels[:MAIN_PANEL].viewport)


    #init bottom screen:
    @panels[@scnscreen]  = SinnohMapBtmScreen.new(@mod,@panels[@scnscreen].viewport,self)
    @panels[@scnscreen].init
    #@panels[@scnscreen].fitSpriteInViewport(@panels[@scnscreen].viewport)

    @panels[@scnscreen].list["detMap"].list["det_Bg"].zoom_x*=2
    @panels[@scnscreen].list["detMap"].list["det_Bg"].zoom_y*=2
    fitInViewports
    deactivate
  end
  
  def activate
    @panels[:MAIN_PANEL].activate
    @panels[@scnscreen].activate
  end

  def init; activate(); end

  def execute
    #refresh bottom screen:
    @panels[@scnscreen].detailMode ||= (MULTI_SCREEN && @panels[@scnscreen].list["Button"].leftClick?(5,0)) || Input.trigger?(Input::USE)
    #@panels[@scnscreen].detailMode &&= !Input.trigger?(Input::BACK) 
    @panels[@scnscreen].update
    
    #refresh top screen:
    MULTI_SCREEN || !@panels[@scnscreen].detailMode ? @panels[:MAIN_PANEL].activate : @panels[:MAIN_PANEL].visible = false
    @panels[:MAIN_PANEL].update if @panels[:MAIN_PANEL].visible
  end
  
  def getTopScreen; return @panels[:MAIN_PANEL]; end
  def getBtmScreen; return @panels[@scnscreen]; end
  def getPanels; return @panels; end
end
#==============================================================================#
#==============================================================================#
#                                SINNOH MAP MODULE                             #
#==============================================================================#
class SinnohMap_Module < SMModule
  include SinnohMap
  def initialize()
    super()
    @mapData = $smMapData
    data = SMapUtil.getData($game_map.map_id)
    @playerPos = data ? data["Pos"] : [0,0]
    @cursorPos = @playerPos.clone
    @curLocId  = nil
    @view = SinnohMapView.new(self)
  end
  
  def execute;
    ret = !Input.trigger?(Input::BACK) #|| @view.getBtmScreen.detailMode
    updatePos
    @curLocId = SMapUtil.pbGetLocationName(@cursorPos)
    @curLocId = "" if !@curLocId
    @view.execute
    return ret
  end
  
  def updatePos
    if Input.press?(Input::UP)
      @cursorPos[1] = (@cursorPos[1] - 1) if @cursorPos[1] > 0
    elsif Input.press?(Input::DOWN)
      @cursorPos[1] = (@cursorPos[1] + 1) if @cursorPos[1] < MAP_HEIGHT_TILES
    end
    
    if Input.press?(Input::LEFT)
      @cursorPos[0] = (@cursorPos[0] - 1) if @cursorPos[0] > 0
    elsif Input.press?(Input::RIGHT)
      @cursorPos[0] = (@cursorPos[0] + 1) if @cursorPos[0] < MAP_WIDTH_TILES
    end
    
    if Input.press?(Input::UP)   || Input.press?(Input::DOWN) || 
       Input.press?(Input::LEFT) || Input.press?(Input::RIGHT)
      #puts("["+@cursorPos[0].to_s+","+@cursorPos[1].to_s+"]") if $DEBUG
      pbWait(CSMOVEPERIOD)
    end
  end

  def getLocs;      return @mapData; end
  def getDesc;      return @mapData[@curLocId]["Common"]["Desc"] if @mapData[@curLocId]; end
  def getCurLocId;  return @curLocId;  end
  def getCursorPos; return @cursorPos; end
  def getPlayerPos; return @playerPos; end
end
#==============================================================================#
def pbDPPTMap
  modulesList = { SinnohMap::ID => SinnohMap_Module.new() }
  scene=SMController.new(modulesList,SinnohMap::ID)
  scene.run
end

def pbShowMap(region=-1,wallmap=true); pbDPPTMap; end
#==============================================================================#