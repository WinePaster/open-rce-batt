# 待硬體確認清單 (Unverified — needs live-device / HCI capture)

> 這些項目靜態分析無法 100% 確定，需用 HCI snoop log 或 nRF Connect 對實機驗證。
> 部分原始項目已被一次實機擷取證實（見 `CAPTURE_VERIFIED.md`）。

## 產品 / 功能歸屬（2026-06 釐清）

- **「斷電」「防盜」是否所有型號都有。** 字串語意（「關閉斷電模式後您即可啟動車輛」「未關閉防盜前請勿強制啟動車輛」）指向**電池型**功能（與發車相關）。哪些按鈕對哪種產品顯示，是由已關閉的雲端 `GetGlobalSetting` 下發決定，**靜態無法確認**。純超級電容的車主回報其裝置主要為監看＋檢測電容。
- **超級電容的「電容異常，已鎖定保護」如何解除。** 這是電容故障時**自動**觸發的保護鎖（狀態 selector 0x27 的 `01680217`→`0218`），與使用者控制的「斷電」不同。清除它的實際指令／位元組**未知**，需要一份**故障電容被成功清除當下**的 HCI 擷取（社群可用 `HCI_CAPTURE_GUIDE.md` 提供）。
- **mode 0x06 的真正語意。** 實機擷取顯示連線後送 `switchMode 0x06 + auth`，但 mode 暫存器只短暫跳 0x06 又回 0x05；它較像連線後的**例行 detect/keep-alive 模式**，而非鎖存式「解鎖」。健康電容根本未鎖，該序列只是常規握手。
- **解除是否真的需要 auth。** 遙測串流不需 auth（擷取中遙測早於 auth 26 秒就在流）。但「只送 mode、不送 auth」是否足以改變鎖定狀態**未證實**——App 提供實驗開關供車上實測。

## 協定細節（仍開放）

- TWF 狀態旗標位元對應（selector 0x20）：程式索引 bit [14],[12],[6],[4]，需 ≥15 字元字串，與單一位元組來源矛盾 — 位元語意不可靠。
- 連線時初始 'detect' 指令的確切位元組（設定 isSentDetect 0x3c）未隔離出來。
- 參數設定 ack 0211–0214（OV/UV/OT/門檻）的逐碼意義為推測；四者都寫同一旗標 offset 0x133。
- 1Hz 輪詢的 device-type 比較：是測 ASCII 'D'(0x44) 還是 Smi-tag 值(34/0x22) 有爭議。
- Capacity/SOH bucket `(n-1)*10+5` 語意（SOH%／SOC%／循環）未知。
- 完整 inbound read-selector 列舉未完（FW 版本、整流檔位、PowerBank Command 7 等）。

## 已由實機擷取證實（不再開放，見 CAPTURE_VERIFIED.md）

- Notify 特徵 = `07b9ace4-…`@0x1b（CCCD 0x1c，寫 `0100` 開啟）。
- 服務 `07b9fff0-…` 範圍 0x0010–0x0023；寫入特徵 `07b9ace3-…`@0x18。
- 無 MTU 協商（預設 23）。switchMode = 15 bytes（mode++auth，無額外尾載）。
- inbound frame byte[2]=固定 0x01、byte[3]=LEN、payload@byte4。
