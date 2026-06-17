#Requires AutoHotkey v2.0
#SingleInstance Force

; Global state variables
IsRunning := false
SelectedTask := "Seeds" ; Default task selection
CurrentStep := 0        ; Track seed state machine steps
EggLoopCounter := 0     ; Track egg loops

; ==========================================
; CREATE THE USER INTERFACE (GUI)
; ==========================================
MainGui := Gui("+AlwaysOnTop -MaximizeBox", "Build A Ring: Multi-Farm")

; Set default font style
MainGui.SetFont("s10", "Segoe UI")

; Header text block (FIXED: Set weight cleanly via SetFont)
MainGui.SetFont("Bold")
MainGui.Add("Text", "w220 Center", "Select Your Automation Task")
MainGui.SetFont("Norm") ; Revert to regular font for the rest of the controls

; Radio button selections for the tasks
RadioSeeds := MainGui.Add("Radio", "vTaskGroup checked y+15 x25", "Auto-Buy Seeds (State Machine)")
RadioEggs := MainGui.Add("Radio", "x25 y+10", "Auto-Buy Eggs (15-Loop Sequence)")

; Event bindings when switching tasks
RadioSeeds.OnEvent("Click", (*) => SetTask("Seeds"))
RadioEggs.OnEvent("Click", (*) => SetTask("Eggs"))

MainGui.Add("Text", "w220 h2 0x10 y+15 x15") ; Horizontal separator visual line

; Control instructions panel
MainGui.Add("Text", "w220 Center cGray y+10", "[F1] to Start / Pause`n[F4] to Safe Exit")

; Status tracker bar label (FIXED: Set weight cleanly via SetFont)
MainGui.SetFont("Bold")
StatusText := MainGui.Add("Text", "w220 Center cRed y+15", "STATUS: IDLE")
MainGui.SetFont("Norm")

MainGui.OnEvent("Close", (*) => CleanExit())
MainGui.Show("w250 h210")

; ==========================================
; SYSTEM MANAGEMENT FUNCTIONS
; ==========================================

SetTask(TaskName) {
    global SelectedTask, IsRunning
    if (IsRunning) {
        ToggleFarm() ; Force pause if user changes selection mid-run
    }
    SelectedTask := TaskName
}

; --- Hotkey F1: Start / Pause ---
~F1:: ToggleFarm()

ToggleFarm() {
    global IsRunning, SelectedTask, StatusText, CurrentStep
    IsRunning := !IsRunning
    
    if (IsRunning) {
        SoundBeep 1000, 150
        StatusText.Text := "STATUS: RUNNING (" SelectedTask ")"
        StatusText.SetFont("cGreen")
        
        if (SelectedTask == "Seeds") {
            CurrentStep := 1 ; Start state machine at step 1
            SetTimer(FarmManager, 10)
        } else if (SelectedTask == "Eggs") {
            ToolTip("บอทเริ่มทำงานแล้ว (F1 เพื่อหยุด)", 10, 10)
            SetTimer(MainEggLoop, 10)
        }
    } else {
        SoundBeep 500, 150
        StatusText.Text := "STATUS: PAUSED"
        StatusText.SetFont("cRed")
        
        ; Turn off all loops/timers
        SetTimer(FarmManager, 0)
        SetTimer(MainEggLoop, 0)
        
        ; Clear all potential stuck keystrokes immediately
        Send("{w up}{s up}{a up}{d up}{e up}")
        ToolTip("หยุดบอทชั่วคราว")
        Sleep 500
        ToolTip ""
    }
}

; --- Hotkey F4: Emergency Close App ---
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
; TASK 1: AUTO-BUY SEEDS (STATE MACHINE)
; ==========================================

FarmManager() {
    global IsRunning, CurrentStep, SelectedTask
    if (!IsRunning || SelectedTask != "Seeds") {
        SetTimer(FarmManager, 0)
        return
    }
    
    ; Pause timer to let current step process safely without overlap
    SetTimer(FarmManager, 0)
    
    switch CurrentStep {
        case 1: ; ดึงคันโยก (กดค้าง 0.75 วินาที)
            HoldE(750)
            NextStep(1, 200) 
            
        case 2: ; รอคูลดาวน์สุ่ม 10 วินาที
            NextStep(2, 10000)
            
        ; --- แถวที่ 1 (3 แท่นหน้า) ---
        case 3: ; เดินไปแท่นกลางหน้า
            Move("w", 400)
            NextStep(3, 200)
        case 4: ; ซื้อแท่นกลางหน้า (กดค้าง 0.75 วินาที)
            HoldE(750)
            NextStep(4, 200)
            
        case 5: ; เดินไปแท่นซ้ายหน้า
            Move("a", 400)
            NextStep(5, 200)
        case 6: ; ซื้อแท่นซ้ายหน้า
            HoldE(750)
            NextStep(6, 200)
            
        case 7: ; เดินไปแท่นขวาหน้า
            Move("d", 800)
            NextStep(7, 200)
        case 8: ; ซื้อแท่นขวาหน้า
            HoldE(750)
            NextStep(8, 200)
            
        case 9: ; เดินกลับมาตั้งหลักตรงกลางแถวหน้า
            Move("a", 400)
            NextStep(9, 200)
            
        ; --- แถวที่ 2 (3 แท่นหลัง) ---
        case 10: ; เดินขึ้นไปแถวหลัง (แท่นกลางหลัง)
            Move("w", 450)
            NextStep(10, 200)
        case 11: ; ซื้อแท่นกลางหลัง
            HoldE(750)
            NextStep(11, 200)
            
        case 12: ; เดินไปแท่นขวาหลัง
            Move("d", 400)
            NextStep(12, 200)
        case 13: ; ซื้อแท่นขวาหลัง
            HoldE(750)
            NextStep(13, 200)
            
        case 14: ; เดินไปแท่นซ้ายหลัง
            Move("a", 800)
            NextStep(14, 200)
        case 15: ; ซื้อแท่นซ้ายหลัง
            HoldE(750)
            NextStep(15, 200)
            
        case 16: ; เดินกลับมาตั้งหลักตรงกลางแถวหลัง
            Move("d", 400)
            NextStep(16, 200)
            
        ; --- เดินกลับจุดเริ่มต้น ---
        case 17: ; ถอยหลังยาวกลับไปที่คันโยก
            Move("s", 850)
            NextStep(17, 200)
            
        case 18: ; พัก 1 วินาทีก่อนเริ่มรอบใหม่
            CurrentStep := 1 ; รีเซ็ตกลับไปขั้นตอนที่ 1
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

    ; Stop timer temporarily while running structural loop blocks
    SetTimer(MainEggLoop, 0)

    ; ** ส่วนที่เพิ่มใหม่: มาถึงที่จุดเริ่มต้นปุ๊บ กด E ค้าง 1 วินาทีก่อนทันที **
    Send("{e down}")
    Sleep(1000)
    Send("{e up}")
    Sleep(150) ; เว้นจังหวะสั้นๆ ก่อนเริ่มเดิน
    
    ; ลูปเดิมของคุณ (ทำทั้งหมด 15 รอบ)
    EggLoopCounter := 0
    while (EggLoopCounter < 15) {
        if (!IsRunning)
            break
            
        ; send e down 
        Send("{e down}")
        Sleep(1000)
        
        ; send e up
        Send("{e up}")
        Sleep(100)
        
        ; for(i in 3) send w down send w up
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

        ; send e down 
        Send("{e down}")
        Sleep(1000)
        
        ; send e up
        Send("{e up}")
        Sleep(100) 
        
        EggLoopCounter++
    } 

    ; send s down (ถอยหลังกลับยาวๆ 10 วินาที)
    if (IsRunning) {
        Send("{s down}")
        Sleep(10000)
        Send("{s up}")
        
        ; พัก 1 วินาที ก่อนที่ SetTimer จะวนลูปกลับไปทำใหม่ตั้งแต่ต้น
        Sleep(1000) 
    }

    ; Reactivate timer if user hasn't paused macro mid-execution
    if (IsRunning && SelectedTask == "Eggs") {
        SetTimer(MainEggLoop, 10)
    }
}
