# $moduledir/progressoservices/manifests/init.pp

class progressoservices($srvsmspass,
                        $srvrsspass,
                        $srvlaimspass,
                        $srvformulacalcpass,
                        $running = true) {
  # resource schecks
  ensure_resource(file, 'D:\SQLScripts', {ensure => directory})
  ensure_resource(file, 'D:\SQLScripts\Accounts', {ensure => directory})

  # Substitution parameters
  $dbuserprefix = upcase($hostname) ? {
    /^SANDBOX.*$/ => 'Sandbox',
    /^DEMO.*$/    => 'Demo',
    /^SUPPORT.*$/ => 'Support',
    /^TRAN.*$/    => 'Tran',
    /^UAT.*$/     => 'Muffin',
    /^LIVE01.*$/  => 'Progresso',
    default       => 'Progresso'
  }

  $dbmis = upcase($hostmane) ? {
    /^LIVE.*$/ => 'Live01DB01',
    /^UAT.*$/  => 'UATDB02',
    default    => $hostname
  }

  $dbrs = upcase($hostmane) ? {
    /^LIVE.*$/ => 'Live01SDB01',
    default    => $hostname
  }

  # Update config files
  file{'config-LearnerAims':
    path    => 'C:\Program Files (x86)\Hewlett-Packard Company\LearnerAimsSetup\LearnerAimsImportService.exe.config',
    ensure  => present,
    content => template('progressoservices/LearnerAimsImportService.erb')
  }
  file{'config-FormulaCalc':
    path    => 'C:\Program Files (x86)\Assessment Formula Calculation\ProgressoFormulaCalculationSetup\ProgressoFormulaCalculation.exe.config',
    ensure  => present,
    content => template('progressoservices/ProgressoFormulaCalculation.erb')
  }
  file{'config-FormulaCalcFTJ':
    path    => 'C:\Program Files\Progresso\ProgressoFormulaCalculationFirstTime\ProgressoFormulaCalculationFirstTime.exe.config',
    ensure  => present,
    content => template('progressoservices/ProgressoFormulaCalculationFirstTime.erb')
  }
  file{'config-SMS':
    path    => 'C:\Program Files (x86)\iGate\ProgressoSMSService Setup\ProgressoSMSService.exe.config',
    ensure  => present,
    content => template('progressoservices/ProgressoSMSService.erb')
  }
  file{'config-RSS':
    path    => 'C:\Program Files\IGATE\Progresso Report Sync Service\ReportServerSync.exe.config',
    ensure  => present,
    content => template('progressoservices/ReportServerSync.erb')
  }

  # password scripts
  file{'createServiceAccounts':
    path   => 'D:\SQLScripts\Accounts\createServiceAccounts.sql',
    ensure => present,
    content => template('progressoservices/sqlscripts/createServiceAccounts.erb')
  }
  file{'resetServicePasswords':
    path   => 'D:\SQLScripts\Accounts\resetServicePasswords.sql',
    ensure => present,
    content => template('progressoservices/sqlscripts/resetServicePasswords.erb')
  }

  # set service status
  if $running = true {
    $enable = true
  } else {
    $enable = 'manual'
  }

  service{'':
    ensure => $running,
    enable => $enable
  }
}
