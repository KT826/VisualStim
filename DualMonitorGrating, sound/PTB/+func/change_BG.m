function change_BG(BG_RGB,MONITOR_rect,expWin)
Screen('FillRect', expWin, BG_RGB, MONITOR_rect);
Screen('Flip', expWin);
end