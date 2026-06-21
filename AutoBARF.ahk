#Requires AutoHotkey v2.0
#SingleInstance Force

; ตัวแปรควบคุมสถานะหลัก
IsRunning := false
SelectedTask := "Seeds" 
CurrentStep := 0        
EggLoopCounter := 0     

; ==========================================
; CREATE THE USER INTERFACE (GUI)
; ==========================================
MainGui := Gui("+AlwaysOnTop -MaximizeBox", "Build A Ring: Multi-Farm")
MainGui.SetFont("s10", "Segoe UI")

MainGui.SetFont("Bold")
MainGui.Add("Text", "w220 Center", "Select Your Automation Task")
MainGui.SetFont("Norm") 

; ปุ่มวิทยุ (Radio) สำหรับเลือกโหมด (เปลี่ยนชื่อเป็น Buy Bee)
RadioSeeds := MainGui.Add("Radio", "vTaskGroup checked y+15 x25", "Auto-Buy Seeds")
RadioEggs := MainGui.Add("Radio", "x25 y+10", "Auto-Buy Eggs")
RadioBuyBee := MainGui.Add("Radio", "x25 y+10", "Buy Bee (Hold E 1 Sec)") ; <--- เปลี่ยนชื่อแสดงผลใน GUI

; ผูกเหตุการณ์เมื่อกดเปลี่ยนโหมด
RadioSeeds.OnEvent("Click", (*) => SetTask("Seeds"))
RadioEggs.OnEvent("Click", (*) => SetTask("Eggs"))
RadioBuyBee.OnEvent("Click", (*) => SetTask("BuyBee")) ; <--- เปลี่ยนชื่อเรียกฟังก์ชันภายใน

MainGui.Add("Text", "w220 h2 0x10 y+15 x15") 
MainGui.Add("Text", "w220 Center cGray y+10", "[F1] to Start / Pause`n[F4] to Safe Exit")

MainGui.SetFont("Bold")
StatusText := MainGui.Add("Text", "w220 Center cRed y+15", "STATUS: IDLE")
MainGui.SetFont("Norm")

MainGui.OnEvent("Close", (*) => CleanExit())
MainGui.Show("w250 h240") 

; ==========================================
; SYSTEM MANAGEMENT FUNCTIONS
; ==========================================

SetTask(TaskName) {
    global SelectedTask, IsRunning
    if (IsRunning) {
        ToggleFarm() 
    }
    SelectedTask := TaskName
}

~F1:: ToggleFarm()

ToggleFarm() {
    global IsRunning, SelectedTask, StatusText, CurrentStep
    IsRunning := !IsRunning
    
    if (IsRunning) {
        SoundBeep 1000, 150
        StatusText.Text := "STATUS: RUNNING (" SelectedTask ")"
        StatusText.SetFont("cGreen")
        
        if (SelectedTask == "Seeds") {
            CurrentStep := 1 
            SetTimer(FarmManager, 10)
        } else if (SelectedTask == "Eggs") {
            ToolTip("บอทเริ่มทำงานแล้ว (F1 เพื่อหยุด)", 10, 10)
            SetTimer(MainEggLoop, 10)
        } else if (SelectedTask == "BuyBee") { ; <--- เงื่อนไขสำหรับ Buy Bee
            ToolTip("บอทเริ่มทำงานแล้ว (F1 เพื่อหยุด)", 10, 10)
            SetTimer(MainBuyBeeLoop, 10)
        }
    } else {
        SoundBeep 500, 150
        StatusText.Text := "STATUS: PAUSED"
        StatusText.SetFont("cRed")
        
        ; ปิดไทเมอร์ทั้งหมด
        SetTimer(FarmManager, 0)
        SetTimer(MainEggLoop, 0)
        SetTimer(MainBuyBeeLoop, 0) ; <--- ปิดไทเมอร์ Buy Bee
        
        Send("{w up}{s up}{a up}{d up}{e up}")
        ToolTip("หยุดบอทชั่วคราว")
        Sleep 500
        ToolTip ""
    }
}

~F4:: CleanExit()

CleanExit() {
    global StatusText
    Send("{w up}{s up}{a up}{d up}{e up}")
    try StatusText.Text := "EXITING..."
    try StatusText.SetFont("cOrange")
    ToolTip("กำลังปิดโปรแกรม...")
    Sleep 500
    ExitApp()
}


; ==========================================
; TASK 1: AUTO-BUY SEEDS (ดีเลย์ 800ms เคลียร์แรงเฉื่อย)
; ==========================================

FarmManager() {
    global IsRunning, CurrentStep, SelectedTask
    if (!IsRunning || SelectedTask != "Seeds") {
        SetTimer(FarmManager, 0)
        return
    }
    
    SetTimer(FarmManager, 0) 
    
    switch CurrentStep {
        case 1: 
            HoldE(750)
            NextStep(1, 800) 
            
        case 2: 
            NextStep(2, 10000)
            
        case 3: 
            Move("w", 400)
            NextStep(3, 800) 
        case 4: 
            HoldE(750)
            NextStep(4, 800)
            
        case 5: 
            Move("a", 400)
            NextStep(5, 800) 
        case 6: 
            HoldE(750)
            NextStep(6, 800)
            
        case 7: 
            Move("d", 400) 
            Sleep(800)     
            Move("d", 400) 
            NextStep(7, 800) 
        case 8: 
            HoldE(750)
            NextStep(8, 800)
            
        case 9: 
            Move("a", 400)
            NextStep(9, 800) 
            
        case 10: 
            Move("w", 450)
            NextStep(10, 800) 
        case 11: 
            HoldE(750)
            NextStep(11, 800)
            
        case 12: 
            Move("d", 400)
            NextStep(12, 800) 
        case 13: 
            HoldE(750)
            NextStep(13, 800)
            
        case 14: 
            Move("a", 400) 
            Sleep(800)     
            Move("a", 400) 
            NextStep(14, 800) 
        case 15: 
            HoldE(750)
            NextStep(15, 800)
            
        case 16: 
            Move("d", 400)
            NextStep(16, 800) 
            
        case 17: 
            Move("s", 850)
            NextStep(17, 800)
            
        case 18: 
            CurrentStep := 1 
            if (IsRunning && SelectedTask == "Seeds") {
                SetTimer(FarmManager, 1000)
            }
    }
}

NextStep(stepNumber, delay) {
    global CurrentStep, IsRunning
    if (IsRunning && CurrentStep == stepNumber) {
        CurrentStep++
        SetTimer(FarmManager, delay)
    }
}

Move(key, duration) {
    Send("{" key " down}")
    Sleep(duration)
    Send("{" key " up}")
}

HoldE(duration) {
    Send("{e down}")
    Sleep(duration)
    Send("{e up}")
}


; ==========================================
; TASK 2: AUTO-BUY EGGS (15-LOOP ENGINE)
; ==========================================

MainEggLoop() {
    global IsRunning, SelectedTask
    
    if (!IsRunning || SelectedTask != "Eggs" || !WinActive("ahk_exe RobloxPlayerBeta.exe"))
        return

    SetTimer(MainEggLoop, 0) 

    Send("{e down}")
    Sleep(1000)
    Send("{e up}")
    Sleep(150) 
    
    EggLoopCounter := 0
    while (EggLoopCounter < 15) {
        if (!IsRunning)
            break
            
        Send("{e down}")
        Sleep(1000)
        Send("{e up}")
        Sleep(100)
        
        Loop 3 {
            if (!IsRunning)
                break
            Send("{w down}")
            Sleep(50) 
            Send("{w up}")
            Sleep(50) 
        }
        
        if (!IsRunning)
            break

        Send("{e down}")
        Sleep(1000)
        Send("{e up}")
        Sleep(100) 
        
        EggLoopCounter++
    } 

    if (IsRunning) {
        Send("{s down}")
        Sleep(10000)
        Send("{s up}")
        Sleep(1000) 
    }

    if (IsRunning && SelectedTask == "Eggs") {
        SetTimer(MainEggLoop, 10)
    }
}


; ==========================================
; TASK 3: BUY BEE (กด E ค้าง 1 วินาทีสลับปล่อย)
; ==========================================

MainBuyBeeLoop() {
    global IsRunning, SelectedTask
    
    if (!IsRunning || SelectedTask != "BuyBee" || !WinActive("ahk_exe RobloxPlayerBeta.exe"))
        return

    SetTimer(MainBuyBeeLoop, 0) 

    ; กด E ค้าง 1 วินาที (1000ms) แล้วปล่อยเพื่อซื้อผึ้ง
    Send("{e down}")
    Sleep(1000)
    Send("{e up}")
    Sleep(100) 

    ; วนลูปกลับมาทำซ้ำ
    if (IsRunning && SelectedTask == "BuyBee") {
        SetTimer(MainBuyBeeLoop, 10)
    }
}
