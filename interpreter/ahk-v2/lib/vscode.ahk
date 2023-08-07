/**
 * **Note: To use this function, you need to have [vscode-operate-from-autohotkey](https://github.com/zero-plusplus/vscode-operate-from-autohotkey) installed on your [VSCode](https://code.visualstudio.com/).**
 * **Also, this function uses the clipboard that in order to cooperate with VSCode. Therefore, if you rewrite the clipboard before or after using this, it may not work correctly.**
 *
 * Execute the VSCode command. If you are using a version lower than v2.0-a110, please rename A_Clipboard to Clipboard.
 * @param {string} commandName -
 *  A string to indicate vscode's command name. You can check it in VSCode's Keyboard Shortcuts (`Ctrl+K`, `Ctrl+S`).
 *
 *  If you want to execute more than one command, separate them with `,`, such as `"command1, command2"`. Any whitespace before or after will be ignored.
 *  Also, If you want to execute a command multiple times, specify such as `"commandName:N"`, where `N` is an arbitrary integer.
 * @param {number|false} [timeout_ms := 1000] - Timeout (in milliseconds). Specify `false` to disable the timeout. For some commands that prompt for user input, it is recommended to specify `false`.
 * @return {string} - The return value of the command (string only). Otherwise, empty string.
 * @example
 *  ExecuteVsCodeCommand("cursorRight")             ; Move the cursor to the right
 *  ExecuteVsCodeCommand("cursorRight:5")           ; Execute the same command five times
 *  ExecuteVsCodeCommand("cursorRight, cursorDown") ; Execute multiple commands
 */
;#Requires AutoHotkey v2.0-beta.1


;ExecuteVsCodeCommand("workbench.action.terminal.toggleTerminal")             ; Move the cursor to the right

; *  ExecuteVsCodeCommand("cursorRight:5")           ; Execute the same command five times
; *  ExecuteVsCodeCommand("cursorRight, cursorDown") ; Execute multiple commands




vscode(commandName, timeout_ms := 1000) {
  ; This function is a minimal implementation that can be understood by people who are not familiar with AutoHotkey
  ; Once you get used to it, you can modify it to make it easier to use
  ; For example, if you can specify a string for a single command to be executed, or an array for multiple commands, it will improve usability
  ;
  ; In the following sections, I will explain each process
  ; 1. Backup the clipboard. This is to restore it before terminating this function
  backup := ClipboardAll()

  ; 2. Stores the command name in the clipboard and sends the shortcut key to invoke the operate-from-autohotkey.executeCommand command
  A_Clipboard := commandName
  SendInput("+^!{F12}")

  ; 3. When the command finishes, a blank character or context information will be written to the clipboard. Wait until then
  startTime := A_TickCount
  while (true) {
    ; Note: Every few dozen times, before the context information is written to the clipboard, a blank character is written for some reason. To avoid false positives, ignore blank
    if (A_Clipboard == "") {
      ; Use a regular expression to reject commands that start with operate-from-autohotkey.copy
      if (commandName ~= "operate-from-autohotkey\.copy.+") {
        continue
      }
      ; Below you should write an unknown command to change the clipboard. If you don't have one, you don't need one
    }

    ; If there are any changes to clipboard, it indicates that the command is finished, so the wait is terminated
    if (A_Clipboard != commandName) {
      break
    }

    ; If the command fails to execute for some reason, an error will be generated when the specified number of milliseconds elapses to prevent infinite waiting
    elapsedTime := A_TickCount - startTime
    if (timeout_ms != false && timeout_ms < elapsedTime) {
      A_Clipboard := backup
      throw Error("Timeout. '" commandName "' was executed. If you want to disable the timeout, specify false as the second parameter of '" A_ThisFunc "'.")
    }

    ; Waits for a short time, because running a continuous loop may cause a load and cause problems with the automation process
    Sleep(1)
  }

  ; 4. Stores the result of the command in a variable. This operation is required to restore the clipboard
  result := A_Clipboard
  A_Clipboard := backup

  ; 5. Congratulations! You can successfully returned the results of the command
  return result
}