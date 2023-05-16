### Q1 how to use FSM with one_shot_pulse

```
//cs
alway@(posedge d_clk, negedge rst_n) begin
    if(!rst_n) ...
    else begin
        cs <= ns;
    end
end

//ns
always@(*) begin
    case(cs)
        IDLE : ns = btm_pulse ? DEAL : IDLE;
        ....
    endcase
end

//out
alway@(posedge d_clk, negedge rst_n) begin
    if(!rst_n) ...
    else begin
        case(cs)
    end
    ...
end

//one_shot
alway@(posedge d_clk, negedge rst_n) begin
    if(!rst_n) ...
    else begin
        press_flag_m <= btn_m;
    end
end

assign btm_pulse = {btn_m,press_flag_m} == 2'b10 ? 1 : 0;
```

### Q2 seg_temp使用範例

