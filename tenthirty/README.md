# 遊戲:十點半

- 需要使用工具
1. 除頻器
2. FSM
3. LUT(會事先提供，作為抽撲克牌用)
4. 3顆LED燈(led[0] : dealer win, led[1] : player win, led[2] : done)
5. 兩顆七段顯示器([7:0] seg and [7:0] seg_l)
6. [7:0] seg7_sel控制七個七段顯示器

## 規則:
首先總共兩人玩，分別為玩家與莊家

按下btn_m即開始抽牌階段

### 抽牌階段:
由玩家先從LUT抽一張牌，接著由莊家抽1張牌

### 補牌階段:
由玩家先開始補牌，按下btn_m即表示抽牌，按下btn_r則表示換下一位玩家 <br>
此時七段顯示器將顯示玩家資訊，右邊5顆七段顯示器會由右往左顯示手牌資訊<br>
左邊三顆七段顯示器則顯示累加數值，一旦補牌超過十點半，則會自動換下一位(即換莊家)
<br>
七段顯示器顯示方式等等介紹
<br>
同理莊家補牌階段，莊家完成後接續比較大小階段

### 比較大小階段:
- 以不超過10.半為原則，比對莊家與玩家的點數大小
- 在莊家與玩家同點的情況下，判定莊家獲勝
- 在莊家與玩家均超過10.半的情況下，判定莊家獲勝
- 若莊家獲勝，led[0]亮起，反之，則由led[1]亮起

比大小完即為完成一個回合，按下btn_r即可開始下個回合 <br>
遊戲一共進行四個回合，四個回合後須狀態機須切換至DONE STATE，同時led[2]亮起

### 七段顯示器顯示方式:
顯示方式如照片所示
<p align="left">
  <img src="pic/seg_display.png" width="300" heigh ="300"/>
</p>

唯一不同處在於抽到10時表示如圖片數字0，若抽到11、12、13，則顯示如下圖
<p align="left">
  <img src="pic/seg_display_11_12_13.jpg" width="200" heigh ="300"/>
</p>

Reset後則顯示如下
<p align="left">
  <img src="pic/reset.jpg" width="500" heigh ="300"/>
</p>

測試影片如下:
https://www.youtube.com/watch?v=E5I9d9Gw6pc&list=PLn0-Y9lYJqqvGrmoE9heed0lfZpIog0h0&index=1
