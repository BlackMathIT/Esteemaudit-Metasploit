# Esteemaudit-Metasploit

This is a porting of the infamous Esteemaudit RDP Exploit leaked from Equationgroup (NSA).
The vulnerability exploited by this attack is related to Smart Card authentication, used when 
logging onto the system via the RDP service. Systems affected are Windows Server 2003 SP1,SP2 
and Windows XP SP0, SP1, SP3.

Dependencies:

- dpkg --add-architecture i386
- apt-get update && apt-get install wine32

How to do:

- Copy the esteemaudit.rb on the right Metasploit folder
(e.g. /usr/share/metasploit-framework/modules/exploits/windows/rdp/)
- Copy only the content of "files" folder on /usr/share/esteemaudit/
- wine /usr/share/esteemaudit/Esteemaudit-2.1.0.exe 2>0   
(This is just to create Wine32 environment, skip it if you already have /root/.wine/drive_c/)

How to mitigate
---------------

Windows server 2003: 
* Run gpedit.msc
* Go to Computer Configuration\Administrative Templates\Windows Components\Terminal Services\Client/Server data redirection\
* Set enable on "Do not allow Smart Card device redirection" 
* Restart the server.

![alt text](http://www.blackmath.it/img/wk3gpo.png)

www.blackmath.it | info@blackmath.it


