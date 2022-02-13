# PS3 Blacklist Sniffer

## Description

* Track your blacklisted people new usernames and IPs.
* Detect blacklisted people who are trying to connect in or who are already in your session.
* You can even use this script without a jailbroken PS3. (only Windows notifications)

**Tested and supported videogames:**

| Videogames                | IP Address Search | PSN Username Search |
| :------------------------ | :---------------: | :-----------------: |
| Minecraft                 | Yes               | Yes                 |
| Sniper Elite 3            | Yes               | Yes                 |
| Red Dead Redemption       | Yes               | Yes                 |
| Grand Theft Auto 5        | Yes               | Yes                 |
| Grand Theft Auto 4        | Yes               | Yes                 |
| Call of Duty: Black Ops 3 | Yes               | No                  |
| Call of Duty: Black Ops 2 | Yes               | No                  |
| Skate 3                   | Yes               | No                  |
| Destiny                   | Yes               | No                  |

## Showcase

| CMD console                |  Windows notification      |
| :-------------------------:|:-------------------------: |
![CMD console](https://user-images.githubusercontent.com/62464560/148648715-848d141e-919b-4f1b-b16f-2a7625ec9945.png) | ![Windows notification](https://user-images.githubusercontent.com/62464560/148648713-fde345d9-8db4-4d6f-a3e9-b95403b290c9.png)
| Blacklist file             |  Logs file                 |
![Blacklist file](https://user-images.githubusercontent.com/62464560/148648714-88a67695-cf36-47c4-9e41-c88ad5fff41d.png) | ![Logs file](https://user-images.githubusercontent.com/62464560/148648806-a32ffe73-f2dc-4342-8cf2-a3677a11315c.png)

## Requirements

* [Windows](https://www.microsoft.com/windows) 10 or 11 (x86/x64)
* [Wireshark](https://www.wireshark.org/)
* [Npcap](https://nmap.org/npcap/) or [Winpcap](https://www.winpcap.org/)
* *optional:* [webMAN MOD](https://github.com/aldostools/webMAN-MOD) (PS3 notifications)

## Credits

@Rosalyn - Giving me the force and motivation<br />
@NotYourDope - Helped me for generating the PS3 console notifications.<br />
@NotYourDope - Helped me for English translations.<br />
@Simi - Helped me for some English translations.<br />
[@Grub4K](https://github.com/Grub4K) - Creator of the timer algorithm.<br />
[@Grub4K](https://github.com/Grub4K) - Creator of the the ending newline detection algorithm.<br />
[@Grub4K](https://github.com/Grub4K) - Quick analysis of the source code to improve it.<br />
[@Grub4K](https://github.com/Grub4K) and [@sintrode](https://github.com/sintrode) - Helped me understand the Windows 7 (x86) `find.exe` command bug with the 65001 codepage.<br />
[@Grub4K](https://github.com/Grub4K) and [@sintrode](https://github.com/sintrode) - Helped me solving and understanding a Batch bug with `for` loop variables.<br />
[@sintrode](https://github.com/sintrode) for: [How to put inner quotes in outer quotes in a `for` loop?](https://www.dostips.com/forum/viewtopic.php?t=6560)<br />

A project started in the [server.bat](https://discord.gg/GSVrHag) Discord server.
