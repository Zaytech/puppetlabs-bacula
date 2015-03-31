# tclient2.zay.net.br

node 'tclient2.zay.net.br' {

  #Instala e ativa pacotes e servicos basicos
  include zayutils
  include zayutils::package
  include zayutils::services

  #Instala e configura mysql 
  class { 'mysql::server':
    root_password    => 'zayth123',
    override_options => {
      'mysqld' => { 
        'connect_timeout' => '60', 
        'bind_address' => '0.0.0.0', 
        'max_connections'  => '100', 
        'max_allowed_packet'  => '512M', 
        'thread_cache_size' => '16', 
        'query_cache_size' => '128M',  } }
  }


  #Instala e configura bacula dir
  class { 'bacula':
    manage_db => true,
    db_backend => 'mysql',
      db_host => 'localhost',
      db_port => '3306',
      db_user => 'teste1',
      db_password => 'zayth123',
      db_database => 'bacula1',

    is_director       => true,
    is_storage        => true,
    is_client         => true,
    manage_console    => true,

    director_password => 'zayth123',
    console_password  => 'zayth123',

    director_server   => 'tclient2.zay.net.br',
    mail_to           => 'admin@zay.net.br',
    storage_server    => 'tclient2.zay.net.br',
  } 


  #Storage
  bacula::director::storage { 'storage1':
     name => 'tclient2:storage', address => 'localhost', device => 'FileStorage' }

  #Pools default's
  bacula::director::pool {'Default': name => 'Default', }
  bacula::director::pool {'File': name => 'File', }

  bacula::director::pool {'Vol:DiarioInternoFull': name => 'Vol:DiarioInternoFull', labelformat => 'VL-DIF-', }
  bacula::director::pool {'Vol:DiarioInternoInc':  name => 'Vol:DiarioInternoInc',  labelformat => 'VL-DII-',  maximumvolumebytes => '30G' }
  bacula::director::pool {'Vol:DiarioInternoDif':  name => 'Vol:DiarioInternoDif',  labelformat => 'VL-DID-',  maximumvolumebytes => '30G' }

  bacula::director::pool {'Vol:DiarioExternoFull': name => 'Vol:DiarioExternoFull', labelformat => 'VL-DEF-', }
  bacula::director::pool {'Vol:DiarioExternoInc':  name => 'Vol:DiarioExternoInc',  labelformat => 'VL-DEI-',  maximumvolumebytes => '30G' }

  #Schedule's
  bacula::director::schedule {'Sch:DiarioInterno1':  name => 'Sch:DiarioInterno1',  runs => ['Level=Full 1st, 3rd sun at 3:00', 'Level=Incremental mon-fri at 23:35' ] }
  bacula::director::schedule {'Sch:DiarioExterno1':  name => 'Sch:DiarioExterno1',  runs => ['Level=VirtualFull 2nd,4th mon at 9:00','Level=Incremental tue-fri at 15:30' ] }

  #filesets
  bacula::director::fileset {'FSet:LinuxDefault':   name => 'FSet:LinuxDefault',    files => ['/etc', '/root', '/var/log' ] }
  bacula::director::fileset {'FSet:LinuxMysqlPath': name => 'FSet:LinuxMysqlPath',  files => ['/var/lib/mysql', '/var/log/mysql' ] }
  bacula::director::fileset {'FSet:LinuxPostgresqlPath': name => 'FSet:LinuxPostgresqlPath',  files => ['/var/lib/postgresql', '/var/log/postgresql' ] }
  bacula::director::fileset {'FSet:WinStserverAdmin':   name => 'FSet:WinStserverAdmin',   options => ['signature = MD5'], files => ['C:/Users/Administrador/' ] }
  bacula::director::fileset {'FSet:WinStserverOutros':  name => 'FSet:WinStserverOutros',  
     options => ['signature = MD5'], 
     files => ['F:/xx1', 'F:/xx2', 'F:/xx3', 'F:/xx.bat' ] }


  #jobdefs
  bacula::director::jobdef { 'JDefs:DiarioInterno':  
     name => 'JDefs:DiarioInterno',  
     priority => '5',  
     schedule_jobdef => 'Sch:DiarioInterno1', 
     pool => 'Vol:DiarioInternoFull', 
       poolfull => 'Vol:DiarioInternoFull', 
       poolinc => 'Vol:DiarioInternoInc' }

  bacula::director::jobdef { 'JDefs:DiarioExterno':  
     name => 'JDefs:DiarioExterno',  
     priority => '5',  
     schedule_jobdef => 'Sch:DiarioExterno1',  
     pool => 'Vol:DiarioExternoFull', 
       poolfull => 'Vol:DiarioExternoFull', 
       poolinc => 'Vol:DiarioExternoInc' }


  #clients e jobs
  bacula::director::client {'Cli:sbackup':    name => 'Cli:sbackup',    address => 'localhost',  password => 'zayth123' }
  bacula::director::client {'Cli:sbackup2':   name => 'Cli:sbackup2',   address => 'localhost',  password => 'zayth123' }
  bacula::director::client {'Cli:sbackupdir': name => 'Cli:sbackupdir', address => 'localhost',  password => 'zayth123' }
  bacula::director::client {'Cli:sbackupsd':  name => 'Cli:sbackupsd',  address => 'localhost',  password => 'zayth123' }



#Jobs diario externo, links

bacula::director::job {'DiarioExterno:Sbackup:LinuxDefault':  jobdefs => 'JDefs:DiarioExterno',
               name => 'DiarioExterno:Sbackup:LinuxDefault', client  => 'Cli:sbackup', fileset => 'FSet:LinuxDefault' }
}




node 'tclient2a.zay.net.br' {

  include zayutils
  include zayutils::package
  include zayutils::services

  class { 'bacula::client':
    director_server   => 'tclient2.zay.net.br',
    director_password => 'zayth123',
    client_package    => 'bacula-client',
  }

}
