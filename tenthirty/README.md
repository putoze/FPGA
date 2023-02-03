# 遊戲：十點半

- 需要使用工具
1. 除頻器
2. FSM
3. LUT(會事先提供，作為抽撲克牌用)
4. 3顆LED燈
5. 兩顆七段顯示器

## 規則:
首先總共兩人玩，分別為玩家與莊家，點數大者即獲勝，詳細規則後續說明

## 遊戲玩法
按下btn_m即開始遊戲，首先進入抽牌階段

### 抽牌階段:
由玩家先抽一張牌，接著由莊家抽1張牌，完成後即進入補牌階段，由玩家先開始補牌

### 補牌階段:
按下btn_m即表示抽牌，如果玩家決定不補牌，按下btn_r則表示換莊家補牌 <br>
若玩家決定補牌，一旦補牌超過十點半，則會自動換莊家，在未超過十點半的情況下，玩家最多可以補四張牌 <br>
同理莊家補牌階段，莊家完成後接續比較大小階段

### 比較大小階段:
- 以不超過10.半為原則，比對莊家與玩家的點數大小，點數大者獲勝
- 在莊家與玩家同點的情況下，判定莊家獲勝
- 在莊家與玩家均超過10.半的情況下，判定莊家獲勝

比大小完即為完成一個回合，按下btn_r即可開始下個回合 <br>
遊戲一共進行四個回合，四個回合後須狀態機須切換至DONE STATE，示意圖如下：
<p align="left">
  <img src="pic/done.jpg" width="400" heigh ="300"/>
</p>

### 七段顯示器

七段顯示器顯示數值如下：
<p align="left">
  <img src="pic/seg_display.png" width="300" heigh ="300"/>
</p>

七段顯示器Reset後則顯示如下：
<p align="left">
  <img src="pic/reset.jpg" width="500" heigh ="300"/>
</p>

若抽到11、12、13，則顯示如下圖：
<p align="left">
  <img src="pic/seg_display_11_12_13.jpg" width="200" heigh ="300"/>
</p>

在玩家補牌階段，右邊5顆七段顯示器會由右往左顯示手牌資訊，最先出現的牌將顯示再最右邊，示意圖如下:
<p align="left">
  <img src="pic/handcard.jpg" width="400" heigh ="300"/>
</p>
左邊三顆七段顯示器則顯示累加數值，如上圖左三顆七段顯示器 <br> <br> <br>

若遇到手牌出現10的情形，則直接顯示0即可，是意圖如下圖最右邊的七段顯示器：
<p align="left">
  <img src="pic/handcardTen.jpg" width="400" heigh ="300"/>
</p>

同理在莊家補牌階段，顯示莊家手牌與累計數值 <br>

在比較大小階段，左三顆顯示莊家累積點數，右三顆顯示玩家累積點數，示意圖如下：
<p align="left">
  <img src="pic/compare.jpg" width="400" heigh ="300"/>
</p>

### LED
完成比大小後，需要亮起LED燈表示完成，亮燈規則如下 <br>
led[0] : 玩家贏 ; led[1] : 莊家贏 ; led[2] : DONE STATE
<p align="left">
  <img src="pic/compare.jpg" width="400" heigh ="300"/>
</p>
上圖由於玩家補牌超過十點半，因此判定莊家獲勝，led[1]亮起 <br><br>

### Data Config
- LUT(look up table)
<p align="left">
  <img src="pic/LUT.png" width="500" heigh ="300"/>
</p>

- TenThirty
<p align="left">
  <img src="pic/tenthirty.png" width="500" heigh ="300"/>
</p>


測試影片如下:
https://www.youtube.com/watch?v=MHQ68WXCOEY&list=PLn0-Y9lYJqqvGrmoE9heed0lfZpIog0h0&index=1 
