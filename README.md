# mpvSockets
create one sockets per mpv instance (with the instance's process **ID** (PID), (**unique**)), instead of one socket for the last started instance

dangling sockets for crashed or killed instances is an issue, 
not sure if this script should handle/remove them or the clients/users, or both.

# Installation
Download the single script file to your mpv-scripts-directory
## Linux / unixes:
``` bash
curl "https://raw.githubusercontent.com/wis/mpvSockets/master/mpvSockets.lua" --create-dirs -o "$Your_Mpv_Scripts_Directory_Location/mpvSockets.lua"
```
if you're on Linux, most likely the location is `~/.config/mpv/scripts`, so run this before:
``` bash
$Your_Mpv_Scripts_Directory_Location=$HOME/config/mpv/scripts
```
## Windows (untested)
powershell:
``` powershell
Invoke-WebRequest -OutFile "$env:LOCALAPPDATA\mpv\scripts\mpvSockets.lua" "https://raw.githubusercontent.com/wis/mpvSockets/master/mpvSockets.lua"
```

# Usage, with Mpv's [JSON IPC](https://github.com/mpv-player/mpv/blob/master/DOCS/man/ipc.rst)
## Linux / unixes (unix sockets):
a script that pauses all running mpv instances:
bash:
``` bash
#!/bin/bash
for i in $(ls /tmp/mpvSockets/*); do
	echo '{ "command": ["set_property", "pause", true] }' | socat - "$i";
done
# Socat  is  a  command  line based utility that establishes two bidirec-tional byte streams  and	 transfers  data  between  them.
# available on Linux and FreeBSD, propably most unixes. you can also use 
```

## Windows (named pipes):
quote from https://mpv.io/manual/stable/#command-prompt-example
> Unfortunately, it's not as easy to test the IPC protocol on Windows, since Windows ports of socat (in Cygwin and MSYS2) don't understand named pipes. In the absence of a simple tool to send and receive from bidirectional pipes, the echo command can be used to send commands, but not receive replies from the command prompt.
>
> Assuming mpv was started with:
>
> `mpv file.mkv --input-ipc-server=\\.\pipe\mpvsocket`
> You can send commands from a command prompt:
>
> `echo show-text ${playback-time} >\\.\pipe\mpvsocket`
To be able to simultaneously read and write from the IPC pipe, like on Linux, it's necessary to write an external program that uses overlapped file I/O (or some wrapper like .NET's NamedPipeClientStream.)

powershell client writer and reader (untested):
``` powershell
# socat.ps1
# usage: socat.ps1 <Pipe-name> <Message>
$sockedName = args[0]
$message = args[1]

$npipeClient = new-object System.IO.Pipes.NamedPipeClientStream('.', $socketName, [System.IO.Pipes.PipeDirection]::InOut, [System.IO.Pipes.PipeOptions]::None, [System.Security.Principal.TokenImpersonationLevel]::Impersonation)

$pipeReader = $pipeWriter = $null
try {
    $npipeClient.Connect()
    $pipeReader = new-object System.IO.StreamReader($npipeClient)
    $pipeWriter = new-object System.IO.StreamWriter($npipeClient)
    $pipeWriter.AutoFlush = $true

    $pipeWriter.WriteLine($message)

    while (($data = $pipeReader.ReadLine()) -ne $null) {
      $data
    }
}
catch {
    "An error occurred that could not be resolved."
}
finally {
    $npipeClient.Dispose()
}
```