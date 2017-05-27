# Esteemaudit-Metasploit

This is a porting of the infamous Esteemaudit RDP Exploit leaked from Equationgroup (NSA).
Vulnerable machines are Windows Server 2003 SP1,SP2 and Windows XP, SP1,SP2, SP3.

Dependencies:

- dpkg --add-architecture i386
- apt-get update && apt-get install wine32

How to do:

- Copy the esteemaudit.rb on the right Metasploit folder
(e.g. /usr/share/metasploit-framework/modules/exploits/windows/rdp/)
- Copy only the content of "files" folder on /usr/share/esteemaudit/
- wine /usr/share/esteemaudit/Esteemaudit-2.1.0.exe 2>0   
(This is just to create Wine32 environment, skip it if you already have /root/.wine/drive_c/)


www.blackmath.it | info@blackmath.it


