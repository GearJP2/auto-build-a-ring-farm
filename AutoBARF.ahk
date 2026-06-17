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

RadioSeeds := MainGui.Add("Radio", "vTaskGroup checked y+15 x25", "Auto-Buy Seeds (Balanced Walk)")
RadioEggs := MainGui.Add("Radio", "x25 y+10", "Auto-Buy Eggs (15-Loop Sequence)")

RadioSeeds.OnEvent("Click", (*) => SetTask("Seeds"))
RadioEggs.OnEvent("Click", (*) => SetTask("Eggs"))

MainGui.Add("Text", "w220 h2 0x10 y+15 x15") 
MainGui.Add("Text", "w220 Center cGray y+10", "[F1] to Start / Pause`n[F4] to Safe Exit")

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
            ResetCameraForSeeds() ; <--- เรียกใช้ระบบล็อกกล้องด้วยคีย์บอร์ดแบบใหม่
            Sleep(500)
            CurrentStep := 1 
            SetTimer(FarmManager, 10)
        } else if (SelectedTask == "Eggs") {
            ResetCameraForEggs()  
            Sleep(500)
            ToolTip("บอทเริ่มทำงานแล้ว (F1 เพื่อหยุด)", 10, 10)
            SetTimer(MainEggLoop, 10)
        }
    } else {
        SoundBeep 500, 150
        StatusText.Text := "STATUS: PAUSED"
        StatusText.SetFont("cRed")
        
        SetTimer(FarmManager, 0)
        SetTimer(MainEggLoop, 0)
        
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
; NEW KEYBOARD-BASED CAMERA SYSTEM (แก้ปัญหากล้องไม่หัน)
; ==========================================

ResetCameraForSeeds() {
    if !WinActive("ahk_exe RobloxPlayerBeta.exe")
        return
        
    ToolTip("กำลังปรับมุมกล้องดิ่งลงพื้น (ด้วยคีย์บอร์ด)...")
    
    ; 1. กดซูมออกก่อนกันบั๊ก
    Loop 4 {
        Send("{o}")
        Sleep(30)
    }
    
    ; 2. กดปุ่มลูกศรลง (Down Arrow) ค้างไว้ 1.5 วินาที เพื่อหมุนกล้องก้มมองพื้นสนิท 100%
    Send("{Down down}")
    Sleep(1500)
    Send("{Down up}")
    Sleep(100)
    
    ; 3. กดซูมเข้า (I) รัวๆ เพื่อเข้าโหมด First Person บังคับมุมมองตั้งฉาก 90 องศาตรงๆ
    Loop 12 {
        Send("{i}")
        Sleep(30)
    }
    ToolTip("")
}

ResetCameraForEggs() {
    if !WinActive("ahk_exe RobloxPlayerBeta.exe")
        return

    ToolTip("กำลังปรับมุมกล้องสำหรับ ซื้อไข่...")
    Loop 8 {
        Send("{o}")
        Sleep(30)
    }
    
    ; เปิด Shift Lock (ตัวละครหันหน้าตรงเป๊ะ)
    Send("{Shift}") 
    Sleep(100)
    
    ; กดลูกศรลงนิดเดียวเพื่อให้มุมกล้องก้มระนาบตู้ไข่พอดี
    Send("{Down down}")
    Sleep(300)
    Send("{Down up}")
    ToolTip("")
}

; ==========================================
; TASK 1: AUTO-BUY SEEDS (เปลี่ยนเป็นเดินสั้น 2 รอบ)
; ==========================================

FarmManager() {
    global IsRunning, CurrentStep, SelectedTask
    if (!IsRunning || SelectedTask != "Seeds") {
        SetTimer(FarmManager, 0)
        return
    }
    
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
        case 4: ; ซื้อแท่นกลางหน้า
            HoldE(750)
            NextStep(4, 200)
            
        case 5: ; เดินไปแท่นซ้ายหน้า
            Move("a", 450) ; ออกซ้ายครั้งที่ 1 (450ms)
            NextStep(5, 200)
        case 6: ; ซื้อแท่นซ้ายหน้า
            HoldE(750)
            NextStep(6, 200)
            
        case 7: ; [แก้ไข] เปลี่ยนจากลากยาว 900ms เป็น ซอยเดินขวาสั้น ๆ 2 รอบแทน
            Move("d", 450) ; เดินขวารอบที่ 1 เพื่อกลับมาตรงกลาง
            Sleep(100)     ; เบรกสั้นลดแรงเฉื่อยตัวละคร
            Move("d", 450) ; เดินขวารอบที่ 2 เพื่อข้ามไปแท่นขวา
            NextStep(7, 200)
        case 8: ; ซื้อแท่นขวาหน้า
            HoldE(750)
            NextStep(8, 200)
            
        case 9: ; เดินกลับมาตั้งหลักตรงกลางแถวหน้า
            Move("a", 450) ; กดซ้ายกลับเข้ากลาง 
            NextStep(9, 200)
            
        ; --- แถวที่ 2 (3 แท่นหลัง) ---
        case 10: ; เดินขึ้นไปแถวหลัง
            Move("w", 450)
            NextStep(10, 200)
        case 11: ; ซื้อแท่นกลางหลัง
            HoldE(750)
            NextStep(11, 200)
            
        case 12: ; เดินไปแท่นขวาหลัง
            Move("d", 450) ; ออกขวาครั้งที่ 1 (450ms)
            NextStep(12, 200)
        case 13: ; ซื้อแท่นขวาหลัง
            HoldE(750)
            NextStep(13, 200)
            
        case 14: ; [แก้ไข] เปลี่ยนจากลากยาว 900ms เป็น ซอยเดินซ้ายสั้น ๆ 2 รอบแทน
            Move("a", 450) ; เดินซ้ายรอบที่ 1 เพื่อกลับมาตรงกลาง
            Sleep(100)     ; เบรกสั้นลดแรงเฉื่อยตัวละคร
            Move("a", 450) ; เดินซ้ายรอบที่ 2 เพื่อข้ามไปแท่นซ้าย
            NextStep(14, 200)
        case 15: ; ซื้อแท่นซ้ายหลัง
            HoldE(750)
            NextStep(15, 200)
            
        case 16: ; เดินกลับมาตั้งหลักตรงกลางแถวหลัง
            Move("d", 450) ; กดขวากลับเข้ากลาง 
            NextStep(16, 250)
            
        ; --- เดินกลับจุดเริ่มต้น ---
        case 17: ; ถอยหลังยาวกลับไปที่คันโยก
            Move("s", 850)
            NextStep(17, 200)
            
        case 18: ; พัก 1 วินาทีก่อนเริ่มรอบใหม่
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
