#Requires AutoHotkey v2.0
#SingleInstance Force

global Toggle := false

; --- ปุ่ม F1: เริ่มต้น / หยุดบอท ---
F1:: {
    global Toggle := !Toggle
    if (Toggle) {
        ToolTip("บอทเริ่มทำงานแล้ว (F1 เพื่อหยุด)", 10, 10)
        SetTimer(MainLoop, 10)
    } else {
        ToolTip("หยุดบอทชั่วคราว")
        SetTimer(MainLoop, 0)
        Send("{w up}{s up}{e up}") ; เคลียร์คีย์ค้างทั้งหมดทันที
        Sleep(500)
        ToolTip()
    }
}

; --- ปุ่ม F4: ปิดสคริปต์ฉุกเฉิน ---
F4:: {
    Send("{w up}{s up}{e up}")
    ToolTip("กำลังปิดโปรแกรม...")
    Sleep(500)
    ExitApp()
}

; === ลูปการทำงานหลัก ===
MainLoop() {
    global Toggle
    
    if (!Toggle || !WinActive("ahk_exe RobloxPlayerBeta.exe"))
        return

    ; ===================================================
    ; ** ส่วนที่เพิ่มใหม่: มาถึงที่จุดเริ่มต้นปุ๊บ กด E ค้าง 1 วินาทีก่อนทันที **
    ; ===================================================
    Send("{e down}")
    Sleep(1000)
    Send("{e up}")
    Sleep(150) ; เว้นจังหวะสั้นๆ ก่อนเริ่มเดิน
    
    ; ===================================================
    ; ลูปเดิมของคุณ (ทำทั้งหมด 15 รอบ)
    ; ===================================================
    i := 0
    while (i < 15) {
        if (!Toggle)
            break
                ; send e down 
        Send("{e down}")
        
        ; sleep(1000)
        Sleep(1000)
        
        ; send e up
        Send("{e up}")
        Sleep(100)
        ; for(i in 3) send w down send w up
        Loop 3 {
            if (!Toggle)
                break
            Send("{w down}")
            Sleep(50) 
            Send("{w up}")
            Sleep(50) 
        }
        
        if (!Toggle)
            break

        ; send e down 
        Send("{e down}")
        
        ; sleep(1000)
        Sleep(1000)
        
        ; send e up
        Send("{e up}")
        Sleep(100) 
        
        ; i++
        i++
    } 

    ; send s down (ถอยหลังกลับาวๆ 10 วินาที)
    if (Toggle) {
        Send("{s down}")
        
        ; sleep(10000)
        Sleep(10000)
        
        ; send s up
        Send("{s up}")
        
        ; พัก 1 วินาที ก่อนที่ SetTimer จะวนลูปกลับไปทำใหม่ตั้งแต่ต้น
        Sleep(1000) 
    }
}