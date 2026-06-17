#Requires AutoHotkey v2.0
#SingleInstance Force

; ตัวแปรควบคุมสถานะ
IsRunning := false
CurrentStep := 0

; กด F1 เพื่อ เปิด/ปิด (Toggle)
F1:: {
    global IsRunning, CurrentStep
    IsRunning := !IsRunning
    
    if (IsRunning) {
        CurrentStep := 1 ; เริ่มที่ขั้นตอนที่ 1
        SetTimer(FarmManager, 10)
    } else {
        SetTimer(FarmManager, 0)
        Send("{w up}{s up}{a up}{d up}{e up}") ; ปล่อยปุ่มทั้งหมดรวมถึง E เมื่อสั่งหยุด
    }
}

; กด F2 เพื่อปิดโปรแกรมทันทีเมื่อเกิดเหตุฉุกเฉิน
F2:: {
    ExitApp()
}

; ฟังก์ชันจัดการลำดับการทำงาน (State Machine)
FarmManager() {
    global IsRunning, CurrentStep
    if (!IsRunning) {
        SetTimer(FarmManager, 0)
        return
    }
    
    ; ปิดเบรกชั่วคราวเพื่อรอให้แต่ละขั้นตอนทำงานเสร็จ ไม่ให้ทำงานซ้อนกัน
    SetTimer(FarmManager, 0)
    
    switch CurrentStep {
        case 1: ; ดึงคันโยก (กดค้าง 0.75 วินาที)
            HoldE(750)
            NextStep(1, 200) ; พักจังหวะสั้นๆ หลังปล่อยปุ่ม
            
        case 2: ; รอคูลดาวน์สุ่ม 10 วินาที
            NextStep(2, 10000)
            
        ; --- แถวที่ 1 (3 แท่นหน้า) ---
        case 3: ; เดินไปแท่นกลางหน้า
            Move("w", 400)
            NextStep(3, 200)
        case 4: ; ซื้อแท่นกลางหน้า (กดค้าง 0.75 วินาที)
            HoldE(750)
            NextStep(4, 200)
            
        case 5: ; เดินไปแท่นซ้ายหน้า (ปรับลดเวลาลงเหลือ 400 จากเดิม 500)
            Move("a", 400)
            NextStep(5, 200)
        case 6: ; ซื้อแท่นซ้ายหน้า
            HoldE(750)
            NextStep(6, 200)
            
        case 7: ; เดินไปแท่นขวาหน้า (ปรับลดเวลาลงเหลือ 800 จากเดิม 1000)
            Move("d", 800)
            NextStep(7, 200)
        case 8: ; ซื้อแท่นขวาหน้า
            HoldE(750)
            NextStep(8, 200)
            
        case 9: ; เดินกลับมาตั้งหลักตรงกลางแถวหน้า (ปรับลดเหลือ 400 ให้บาลานซ์กับทางซ้าย)
            Move("a", 400)
            NextStep(9, 200)
            
        ; --- แถวที่ 2 (3 แท่นหลัง) ---
        case 10: ; เดินขึ้นไปแถวหลัง (แท่นกลางหลัง)
            Move("w", 450)
            NextStep(10, 200)
        case 11: ; ซื้อแท่นกลางหลัง
            HoldE(750)
            NextStep(11, 200)
            
        case 12: ; เดินไปแท่นขวาหลัง (ปรับลดเวลาลงเหลือ 400 จากเดิม 500)
            Move("d", 400)
            NextStep(12, 200)
        case 13: ; ซื้อแท่นขวาหลัง
            HoldE(750)
            NextStep(13, 200)
            
        case 14: ; เดินไปแท่นซ้ายหลัง (ปรับลดเวลาลงเหลือ 800 จากเดิม 1000)
            Move("a", 800)
            NextStep(14, 200)
        case 15: ; ซื้อแท่นซ้ายหลัง
            HoldE(750)
            NextStep(15, 200)
            
        case 16: ; เดินกลับมาตั้งหลักตรงกลางแถวหลัง (ปรับลดเหลือ 400)
            Move("d", 400)
            NextStep(16, 200)
            
        ; --- เดินกลับจุดเริ่มต้น ---
        case 17: ; ถอยหลังยาวกลับไปที่คันโยก
            Move("s", 850)
            NextStep(17, 200)
            
        case 18: ; พัก 1 วินาทีก่อนเริ่มรอบใหม่
            CurrentStep := 1 ; รีเซ็ตกลับไปขั้นตอนที่ 1
            if (IsRunning) {
                SetTimer(FarmManager, 1000)
            }
    }
}

; ฟังก์ชันย้ายไปขั้นตอนถัดไปตามเวลาที่กำหนด
NextStep(stepNumber, delay) {
    global CurrentStep, IsRunning
    if (IsRunning && CurrentStep == stepNumber) {
        CurrentStep++
        SetTimer(FarmManager, delay)
    }
}

; ฟังก์ชันสั่งเดินธรรมดา
Move(key, duration) {
    Send("{" key " down}")
    Sleep(duration)
    Send("{" key " up}")
}

; ฟังก์ชันสั่งกดปุ่ม E ค้างไว้ตามเวลาที่กำหนด (มิลลิวินาที)แล้วค่อยปล่อย
HoldE(duration) {
    Send("{e down}")
    Sleep(duration)
    Send("{e up}")
}